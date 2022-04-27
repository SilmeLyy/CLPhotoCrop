# CLPhotoCrop

[![CI Status](https://img.shields.io/travis/leiyuyu/CLPhotoCrop.svg?style=flat)](https://travis-ci.org/leiyuyu/CLPhotoCrop)
[![Version](https://img.shields.io/cocoapods/v/CLPhotoCrop.svg?style=flat)](https://cocoapods.org/pods/CLPhotoCrop)
[![License](https://img.shields.io/cocoapods/l/CLPhotoCrop.svg?style=flat)](https://cocoapods.org/pods/CLPhotoCrop)
[![Platform](https://img.shields.io/cocoapods/p/CLPhotoCrop.svg?style=flat)](https://cocoapods.org/pods/CLPhotoCrop)

## Example

- 导入头文件

```objc
  #import "CLPhotoCrop.h"
```

- 跳转

```objc
  CLPhotoShopViewController *vc = [[CLPhotoShopViewController alloc] init];
  vc.orgImage = [UIImage clp_imageNamed:@"bg"];
  vc.delegate = self;
  [self presentViewController:vc animated:true completion:nil];
```

- 代理

```objc
  ///CLPhotoShopViewControllerDelegate
  - (void)CLPhotoShopViewControllerFinishImage:(UIImage *)image {
    self.imageView.image = image;
  }
```

## Installation

CLPhotoCrop is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CLPhotoCrop'
```

## Author

leiyuyu, leiyuyu1993@163.com

## License

CLPhotoCrop is available under the MIT license. See the LICENSE file for more info.
