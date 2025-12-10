//
//  SwipeCardPagerView.swift
//  ImageSlider
//
//  Created by Noman belim on 10/12/25.
//

import Foundation
import SwiftUI
import UIKit
import PhotosUI
import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0  // unlimited images
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let uiImage = image as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.selectedImages.append(uiImage)
                        }
                    }
                }
            }

        }
    }
}
struct CardStackView: View {
    @ObservedObject var vm: SwipeViewModel
    let cardWidth: CGFloat
    let cardHeight: CGFloat

    var body: some View {
        ZStack {
            ForEach(vm.cards) { card in
                SwipeCardView(
                    card: card,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight
                ) { _ in
                    vm.removeTopCard()
                }
            }
        }
        .frame(width: cardWidth, height: cardHeight)
    }
}

 
struct SwipeCardView: View {
    let card: SwipeCardModel
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let onRemove: (Bool) -> Void

    @State private var offset: CGSize = .zero

    var body: some View {
        Image(uiImage: card.image)
            .resizable()
//            .scaledToFill()
            .frame(width: cardWidth, height: cardHeight)
            .clipped()
            .cornerRadius(20)
            .shadow(radius: 8)
            .offset(offset)
            .rotationEffect(.degrees(Double(offset.width / 10)))
            .gesture(
                DragGesture()
                    .onChanged { value in offset = value.translation }
                    .onEnded { _ in
                        if offset.width > 120 { onRemove(true) }
                        else if offset.width < -120 { onRemove(false) }
                        else { offset = .zero }
                    }
            )
            .animation(.spring(), value: offset)
    }
}





public struct SwipeCardModel: Identifiable {
    public let id = UUID()
    public let image: UIImage

    public init(image: UIImage) {
        self.image = image
    }
}


public struct SwipeCardPagerView: View {
    
    @StateObject private var vm: SwipeViewModel
    
    private let cardWidth: CGFloat
    private let cardHeight: CGFloat

    public init(
        imageNames: [String],
        cardWidth: CGFloat = 320,
        cardHeight: CGFloat = 450
    ) {
        let uiImages = imageNames.compactMap { UIImage(named: $0) }
        _vm = StateObject(wrappedValue: SwipeViewModel(images: uiImages))
        self.cardWidth = cardWidth
        self.cardHeight = cardHeight
    }

    public init(
        uiImages: [UIImage],
        cardWidth: CGFloat = 320,
        cardHeight: CGFloat = 450
    ) {
        _vm = StateObject(wrappedValue: SwipeViewModel(images: uiImages))
        self.cardWidth = cardWidth
        self.cardHeight = cardHeight
    }

    public var body: some View {
        CardStackView(vm: vm, cardWidth: cardWidth, cardHeight: cardHeight)
    }
}


public class SwipeViewModel: ObservableObject {
    @Published public var cards: [SwipeCardModel] = []

    public init(images: [UIImage]) {
        self.cards = images.map { SwipeCardModel(image: $0) }.reversed()
    }

    public func removeTopCard() {
        if !cards.isEmpty {
            cards.removeLast()
        }
    }
}


