# UIDrawer
UIDrawer is a customizable UIPresentationController that allows modals to be presented like a bottom sheet. The kind of presentation style you can see on the Maps app on iOS.

It supports :
- Dragging up and down
- Multiple snap points (half and top)
- Swipe down to close
- Customization

## Screenshot

![Demo screenshot](https://raw.githubusercontent.com/Que20/UIDrawer/master/demo.gif)

## Installation

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate Alamofire into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "Que20/UIDrawer" ~> 1.0
```

## Usage

Present your drawer like a normal modal with a presentation style set as custom and set a transition delegate :

    let viewController = MyViewController()
    viewController.modalPresentationStyle = .custom
    viewController.transitioningDelegate = self
    self.present(viewController, animated: true)

To your `transitionDelegate`, implement the `presentationController` func, and return a `DrawerPresentationController`.

    extension ViewController: UIViewControllerTransitioningDelegate {
        func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
            return DrawerPresentationController(presentedViewController: presented, presenting: presenting)
        }
    }

Here `ViewController` is the controller that presents the drawer.

## Customization

You can customize the DrawerPresentationController by setting :
- The blur effect style
- The modal's corner radius
- The modal's with
- The gap from the top of the modal to the top of the parent

      let presentationController = DrawerPresentationController(presentedViewController: presented, presenting: presenting)
      
      presentationController.blurEffectStyle = .extraLight
      presentationController.cornerRadius = 20
      presentationController.roundedCorners = [.topLeft, .topRight]
      presentationController.modalWidth = 200
      presentationController.topGap = 80
      presentationController.bounce = true

## Evolutions

A quick todo list for features I want to implement in the futur :
- Custom snap points
- Automatic handling of scrollview's gesture (e.g. a modal that would have a TableView) to swipe up the drawer

## Contribute

Please ;)
