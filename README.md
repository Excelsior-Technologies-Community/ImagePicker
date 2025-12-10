
# 📦 **ImagePicker / SwipeCardPagerView – Swift Package**

A lightweight Swift Package that gives you a **Tinder-style swipe card pager**.
Developers can pass **any images they want** using asset names or `UIImage` objects.

---

# 🚀 **1. Add Dependency to Your Project**

### **Step 1: Open Xcode → File → Add Packages…**

### **Step 2: Paste the package URL**

```
https://github.com/Excelsior-Technologies-Community/ImagePicker.git
```

### **Step 3: Add `ImagePicker` library to your project target**

Done! The package is now installed.

---

# 📥 **2. Import the Package**

In any SwiftUI file where you want to use the swipe pager:

```swift
import ImagePicker
```

---

# 🎨 **3. Use SwipeCardPagerView in Your ContentView**

### **Option A — Using Asset Image Names**

```swift
import SwiftUI
import ImagePicker

struct ContentView: View {
    var body: some View {
        SwipeCardPagerView(
            imageNames: [
                "Image1",
                "Image2",
                "Image3",
                "Image4",
                "Image5"
            ],
            cardWidth: 300,
            cardHeight: 500
        )
    }
}
```

---

### **Option B — Using UIImage Array (custom images)**

```swift
import SwiftUI
import ImagePicker

struct ContentView: View {
    let customImages: [UIImage] = [
        UIImage(named: "apple")!,
        UIImage(named: "banana")!,
        UIImage(named: "dog")!
    ]

    var body: some View {
        SwipeCardPagerView(
            uiImages: customImages,
            cardWidth: 300,
            cardHeight: 500
        )
    }
}
```

---

# ⚙️ **4. Customization Options**

| Parameter    | Description            | Default |
| ------------ | ---------------------- | ------- |
| `imageNames` | Asset names to display | —       |
| `uiImages`   | Array of UIImages      | —       |
| `cardWidth`  | Width of swipe card    | 320     |
| `cardHeight` | Height of swipe card   | 450     |

Example:

```swift
SwipeCardPagerView(
    imageNames: ["Image1", "Image2"],
    cardWidth: 280,
    cardHeight: 420
)
```

---

# 🎉 **Done!**
 