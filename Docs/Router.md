## Router

### 简介

底层是使用 ```UIKit``` 的 ```UINavigationController``` 和 ```UIHostingController + SwiftUI View``` 来达成的

---

### 使用方式

1. ```View``` 继承自 ```RouteableView```   
   
```
struct TestView: RouteableView {

}
```

```RouteableView``` 的定义是 ```typealias RouteableView = View & RouterContentDelegate```

---

2. 选择实现 ```RouterContentDelegate```

```
struct TestView: RouteableView {
    var title: String {
        return "ViewTitle"
    }
}
```

增加的 ```RouterContentDelegate``` 协议作为 ```UIHostingController``` 和 ```SwiftUI View``` 的桥梁 (因为有很多的设置项需要在两端都设置), 后期如果需要还可以继续扩展.

目前必须实现的方法只有 ```var title: String { get }``` 其余方法均有默认实现.

```
protocol RouterContentDelegate {

    /// SwiftUI 需要此项设置 NavigationBar.Title, UIHostingController 需要此项来平滑 push 动画
    var title: String { get }
    
    /// SwiftUI 需要此项设置 NavigationBar.Hidden, UIHostingController 需要此项来平滑 push 动画, 默认为 false
    var isNavigationBarHidden: Bool { get }
    
    /// SwiftUI 和 UIHostingController 都需要此项设置 TitleDisplayMode, 默认为 .inline
    var navigationBarTitleDisplayMode: NavigationBarItem.TitleDisplayMode { get }
    
    /// 针对某些想要独立于 ThemeManager 设置的 View 使用, 默认为 nil
    var forceColorScheme: UIUserInterfaceStyle? { get }
    
    /// 后退按钮的点击事件, 默认为 Router.pop()
    func backButtonAction()
}
```

---

3. 在 ```Root View``` 上调用```applyRouteable```

```
struct TestView: RouteableView {
    var title: String {
        return "NaviTitle"
    }

    var body: some View {
        VStack {
            Text("test")
        }
        .applyRouteable(self)
    }
}
```

```applyRouteable``` 会帮你做如下几件事:

```
@ViewBuilder func applyRouteable(_ config: RouterContentDelegate) -> some View {
    navigationBarBackButtonHidden(true)
        .navigationBarHidden(config.isNavigationBarHidden)
        .navigationTitle(config.title)
        .navigationBarTitleDisplayMode(config.navigationBarTitleDisplayMode)
}
```

---

4. 在 ```RouteMap``` 内增加实现
```
extension RouteMap {
    enum Test {
        case root
    }
}

extension RouteMap.Test: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .root:
            navi.push(content: TestView())
        }
    }
}
```
具体方式跟目前项目中 ```Moya``` 的使用方式非常相似, 可直接查看 ```RouteMap.swift``` 文件了解, 在此不再赘述.

```UINavigationController``` 中增加了两个 helper 方法
* ```push(content:)``` - 在当前的 NaviVC 上 push contentView
* ```present(content:)``` - 在当前的 NaviVC 上 present(modal) contentView, 默认会包一层 ```UINavigationController```

---

5. 在需要跳转时调用 ```Router.route()```
```
Router.route(to: RouteMap.Test.root)
```

---

### 其他补充

* ```Router``` 内的方法默认会在主线程上运行, 所以使用时不需要考虑线程问题.
* ```Router``` 目前支持的方法有 ```pop()```, ```popToRoot()```, ```dismiss()```, 之后如果需要可以继续扩展.
* ```Coordinator.swift``` 默认管理 ```App RootView``` 相关的逻辑, 如果需要可以在这里修改.