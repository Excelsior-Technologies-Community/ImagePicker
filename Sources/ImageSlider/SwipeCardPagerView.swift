//
//  SwipeCardPagerView.swift
//  ImageSlider
//
//  Created by Noman belim on 10/12/25.
 

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
                    cardHeight: cardHeight,
                    onRemove: { _ in vm.removeTopCard() },
                    canSwipe: vm.canSwipe
                )
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
    let canSwipe: Bool

    @State private var offset: CGSize = .zero
    @State private var isRemoving = false

    var body: some View {
        Image(uiImage: card.image)
            .resizable()
            .frame(width: cardWidth, height: cardHeight)
            .clipped()
            .cornerRadius(20)
            .shadow(radius: 8)
            .rotationEffect(.degrees(Double(offset.width / 20)))
            .offset(offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        guard canSwipe, !isRemoving else { return }
                        offset = value.translation
                    }
                    .onEnded { _ in
                        guard canSwipe, !isRemoving else { return }
                        handleSwipe()
                    }
            )
            .animation(.interactiveSpring(response: 0.55,
                                          dampingFraction: 0.65,
                                          blendDuration: 0.3),
                       value: offset)
    }

    private func handleSwipe() {
        let threshold: CGFloat = 120

        if offset.width > threshold { animateRemoval(toRight: true) }
        else if offset.width < -threshold { animateRemoval(toRight: false) }
        else { offset = .zero }
    }

    private func animateRemoval(toRight: Bool) {
        isRemoving = true

        let screenWidth = UIScreen.main.bounds.width * 1.5

        withAnimation(.easeInOut(duration: 0.45)) {
            offset = CGSize(width: toRight ? screenWidth : -screenWidth,
                            height: offset.height)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            onRemove(toRight)
        }
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
    @Published public var canSwipe: Bool = true

    public init(images: [UIImage]) {
        self.cards = images.map { SwipeCardModel(image: $0) }.reversed()
    }

    public func removeTopCard() {
        guard canSwipe else { return }

        if !cards.isEmpty {
            cards.removeLast()
        }

        canSwipe = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { // swipe delay
            self.canSwipe = true
        }
    }
}




