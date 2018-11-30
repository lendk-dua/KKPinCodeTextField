## KKPinCodeTextField

A customizable verification code textField. Can be used for phone verification codes, passwords etc.

![](Screenshots/example.gif)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 8.0+

## Installation

KKPinCodeTextField is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'KKPinCodeTextField'
```

## Usage

1. Interface Builder:

Add a `UITextView` in your *Interface Builder* and change the class of a textView from `UITextView` to `KKPinCodeTextView`. You can set the properties in the *Attributes Inspector* and see a live preview

![](Screenshots/usage.gif)

2. Programmatically:

```objc
KKPinCodeTextField *textField = [[KKPinCodeTextField alloc] initWithFrame:frame];
[self.view addSubview:textField];
```

## Properties

| Property | Type | Description | Default value |
| ---- | :---: | --- | --- |
| ```digitsCount``` | NSUInteger  | Verification code length | 4
| ```borderHeight``` | CGFloat  | Bottom borders height | 4
| ```bordersSpacing``` | CGFloat  | Spacing between bottom borders | 10
| ```filledDigitBorderColor``` | UIColor  | Bottom border color when digit is filled | UIColor.lightGrayColor
| ```emptyDigitBorderColor``` | UIColor  | Bottom border color when digit is empty | UIColor.redColor

## Author

Amirzhan, idryshev@kolesa.kz

## Contributing

Bug reports and pull requests are welcome

## License

KKPinCodeTextField is available under the MIT License. See the [LICENSE](./LICENSE) file for more info.
