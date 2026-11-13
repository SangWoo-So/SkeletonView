# Change Log
All notable changes to this project will be documented in this file

### Next version

#### 🙌 New
* Support `UITableViewDiffableDataSource` and `UICollectionViewDiffableDataSource` with `registerSkeletonCell(_:forCellReuseIdentifier:)` / `registerSkeletonCell(_:forCellWithReuseIdentifier:)`. `apply` no longer crashes while the skeleton is shown. The number of skeleton sections and rows/items can be set, and by default the skeleton fills the view.
* Diffable table views: skeleton `rowHeight` (for `automaticDimension` tables), skeleton section headers (`viewForHeaderInSection` / `heightForHeaderInSection`) and several skeleton cells (`registerSkeletonCell((type:identifier:)...)` with `cellIdentifierForRowAt` / `prepareCellForSkeleton`).

#### 🔬 Improvements
* [**369**](https://github.com/Juanpe/SkeletonView/pull/369): remove useless corner radius constraint - [@Juanpe](https://github.com/Juanpe)
* [**357**](https://github.com/Juanpe/SkeletonView/pull/357): Removed duplicate code in SkeletonCollectionDelegate. - [@keshavamurthy1](https://github.com/keshavamurthy1)
  
#### 🩹 Bug fixes
* [**359**](https://github.com/Juanpe/SkeletonView/pull/359): SkeletonView respecting Font's height, rather than the `UIView` actual height. - [@keshavamurthy1](https://github.com/keshavamurthy1)


## 📦 [1.11.0](https://github.com/Juanpe/SkeletonView/releases/tag/1.11.0)

#### 🙌 New
* [**339**](https://github.com/Juanpe/SkeletonView/pull/339): Add `hiddenWhenSkeletonIsActive` property - [@mohn93](https://github.com/mohn93)
* [**341**](https://github.com/Juanpe/SkeletonView/pull/341): Support autoreverses in gradient animations - [@Juanpe](https://github.com/Juanpe)

#### 🔬Improvements
* [**344**](https://github.com/Juanpe/SkeletonView/pull/344): Resize labels based on number of lines - [@Juanpe](https://github.com/Juanpe)

#### 🩹 Bug fixes
* [**340**](https://github.com/Juanpe/SkeletonView/pull/340): Fixed incorrect padding, and incorrect multiline layer frame calculation - [@yzhao198](https://github.com/yzhao198)

## 📦 [1.10.0](https://github.com/Juanpe/SkeletonView/releases/tag/1.10.0)

#### 🙌 New
* [**327**](https://github.com/Juanpe/SkeletonView/pull/327): Add SwiftLint - [@Juanpe](https://github.com/Juanpe)
* [**329**](https://github.com/Juanpe/SkeletonView/pull/329): Spanish README 🇪🇸 - [@Juanpe](https://github.com/Juanpe)

#### 🩹 Bug fixes
* [**336**](https://github.com/Juanpe/SkeletonView/pull/336): Not replace text when the skeleton disappears. Solved issues: [#296](https://github.com/Juanpe/SkeletonView/issues/296), [#330](https://github.com/Juanpe/SkeletonView/issues/330) - [@Juanpe](https://github.com/Juanpe)
* [**337**](https://github.com/Juanpe/SkeletonView/pull/337): RTL support. Solved issues: [#143](https://github.com/Juanpe/SkeletonView/issues/143) - [@Juanpe](https://github.com/Juanpe)

## 📦 [1.9](https://github.com/Juanpe/SkeletonView/releases/tag/1.9)

#### 🩹 Bug fixes
* [**319**](https://github.com/Juanpe/SkeletonView/pull/319): Fix to consider the top and bottom edge insets when updating the skeleton layer height - [@xpereta](https://github.com/xpereta)
* [**320**](https://github.com/Juanpe/SkeletonView/pull/320): Fix Single line customisation - [@Juanpe](https://github.com/juanpe)
* [**323**](https://github.com/Juanpe/SkeletonView/pull/323): Save and restore view state for UIButton - [@Juanpe](https://github.com/juanpe)

## 📦 [1.8.8](https://github.com/Juanpe/SkeletonView/releases/tag/1.8.8)

#### 🙌 New
* [**304**](https://github.com/Juanpe/SkeletonView/pull/304): French README 🇫🇷 - [@OmarJalil](https://github.com/OmarJalil)

#### 🔬Improvements
* [**311**](https://github.com/Juanpe/SkeletonView/pull/311): Bump json from 2.2.0 to 2.3.1 - [@dependabot](https://github.com/dependabot)

#### 🩹 Bug fixes
* [**286**](https://github.com/Juanpe/SkeletonView/pull/286): Fix issue when WKWebView calls skeletonLayoutSubviews not on the main thread - [@paulanatoleclaudot-betclic](https://github.com/paulanatoleclaudot-betclic)
* [**292**](https://github.com/Juanpe/SkeletonView/pull/292): Fix IBInspectable support when using Carthage - [@marisalaneous](https://github.com/marisalaneous)
* [**308**](https://github.com/Juanpe/SkeletonView/pull/308): Fix example backgroundColor in DarkMode - [@toshi0383](https://github.com/toshi0383)
* [**307**](https://github.com/Juanpe/SkeletonView/pull/307): Prevent incorrect skeletonLayer to be added when updating skeleton - [@wsalim1610](https://github.com/wsalim1610)

## 📦 [1.8.7](https://github.com/Juanpe/SkeletonView/releases/tag/1.8.7)

#### 🔬Improvements
* [**271**](https://github.com/Juanpe/SkeletonView/pull/271): Add corner radius for skeletonView as IBInspectable (CGFloat) default is 0.0 - [@paulanatoleclaudot-betclic](https://github.com/paulanatoleclaudot-betclic)

#### 🩹 Bug fixes
* [**259**](https://github.com/Juanpe/SkeletonView/issues/259): Prevent isSkeletonActive to be called when isSkeletonable is false - [@wsalim1610](https://github.com/wsalim1610)
* [**274**](https://github.com/Juanpe/SkeletonView/pull/274): Fix: hiding skeleton when header and footer views of section would not hide it - [@darkside999](https://github.com/darkside999)
* [**273**](https://github.com/Juanpe/SkeletonView/pull/273): Fix: in vertical stack view with center alignment show incorrect position - [@koooootake](https://github.com/koooootake)

## 📦 [1.8.6](https://github.com/Juanpe/SkeletonView/releases/tag/1.8.6)

#### 🔬Improvements
* [**242**](https://github.com/Juanpe/SkeletonView/pull/242): Offscreen table view layout issue fixed - [@Cacodemon](https://github.com/Cacodemon)
* [**261**](https://github.com/Juanpe/SkeletonView/pull/261): Fixes removing skeleton layers from table header footer sections - [@darkside999](https://github.com/darkside999)
* [**263**](https://github.com/Juanpe/SkeletonView/pull/263): Feature/set cross dissolve transitions as default - [@Juanpe](https://github.com/Juanpe)
* [**264**](https://github.com/Juanpe/SkeletonView/pull/264): not replace original datasource is running XCTests - [@Juanpe](https://github.com/Juanpe)
* [**265**](https://github.com/Juanpe/SkeletonView/pull/265): call original traitCollectionDidChange method - [@Juanpe](https://github.com/Juanpe)

#### 🩹 Bug fixes
* [**260**](https://github.com/Juanpe/SkeletonView/issues/260): Don't hide skeleton layers on TableViewHeaderFooterView
* [**257**](https://github.com/Juanpe/SkeletonView/issues/257): Unit test problem when using SkeletonView


## 📦 [1.8.3](https://github.com/Juanpe/SkeletonView/releases/tag/1.8.3)

- Support for iOS 13 dark mode. (thanks @Wilsonator5000)

## 📦 [1.8.2](https://github.com/Juanpe/SkeletonView/releases/tag/1.8.2)

#### 🙌 New
- Add ability to customize line spacing per label. (thanks @gshahbazian)

## 📦 [LayoutSkeleton (1.8.1)](https://github.com/Juanpe/SkeletonView/releases/tag/1.8.1)

#### 🔬Improvements
- Fix completion call in .none transition style while hide skeletons. (thanks @aadudyrev)

#### 🙌 New
- Swizzle `layoutSubviews` method.

#### 🔬Improvements
- Fix completion call in .none transition style while hiding skeletons. (thanks @aadudyrev)
- Swift format.

#### 🩹 Bug fixes
- Update layout subviews when the original method is called.
   - Issues: [#88, #149]

## 📦 [Transitions (1.8)](https://github.com/Juanpe/SkeletonView/releases/tag/1.8)

#### 🙌 New

- Adding swift news to mentioned section (thanks @osterbergmarcus).
- Create `SkeletonTransitionStyle`. Now, you can animate transition when you show or hide skeletons. (thanks @pontusjacobsson)

#### 🔬Improvements
- Refactor some methods.

#### 🩹 Bug fixes
- Solved issues.
 [#175](https://github.com/Juanpe/SkeletonView/issues/175) Swift Package Manager version format

## 📦 [Layout update (1.7)](https://github.com/Juanpe/SkeletonView/releases/tag/1.7)

#### 🙌 New

- Allow updating skeleton layout to recalculate skeleton bounds: `layoutSkeletonIfNeeded`. See the examples to know how to use it. (thanks @eduardbosch)

#### 🔬Improvements

- Allow updating skeleton layers without recreating them: `updateSkeleton`, `updateGradientSkeleton`, `updateAnimatedSkeleton`, `updateAnimatedGradientSkeleton`. (thanks @eduardbosch)

## 📦 [Debug (1.4)](https://github.com/Juanpe/SkeletonView/releases/tag/1.4)

#### 🙌 New

- Create `skeletonDescription` print a skeleton representation of the view.
- Create `SKELETON_DEBUG` environment variable, in order to print the view hierarchy when the skeleton appears.

#### 🔬Improvements
- Add two new methods to `SkeletonFlowDelegate` protocol. Now you can know when the skeleton did show and when it did hide.
- `Recursive` protocol

#### 🩹 Bug fixes
- Solved issue [#86](https://github.com/Juanpe/SkeletonView/issues/86) (thanks @reececomo)

## 📦 [Custom defaults (1.3)](https://github.com/Juanpe/SkeletonView/releases/tag/1.3)

#### 🙌 New

- Default values customizables. Now you can set the default values of Skeleton appearance.(thanks @reececomo)
  - issues: [[#50](https://github.com/Juanpe/SkeletonView/issues/50), [#83](https://github.com/Juanpe/SkeletonView/issues/83)]

#### 🩹 Bug fixes
- Solved issue [#41](https://github.com/Juanpe/SkeletonView/issues/41). Now, Skeleton works if UICollectionView cell's Nib is registered in code. (thanks @kjoneandrei)

## 📦 [Typo (1.2.3)](https://github.com/Juanpe/SkeletonView/releases/tag/1.2.3)

####  Fixes

- Fix typo in `SkeletonTableViewDataSource` protocol

#### 🔬Improvements

- Now it takes in account the `UIStackView` to calculate the `SkeletonLayer` bounds (thanks @giantramen)

## 📦 [New face (1.2.2)](https://github.com/Juanpe/SkeletonView/releases/tag/1.2.2)

#### 🙌 New

- Rebranding

#### 🩹 Bug fixes
- Solved issue [#23](https://github.com/Juanpe/SkeletonView/issues/23). Problem with UIStackView. (thanks @giantramen)

## 📦 [State (1.2.1)](https://github.com/Juanpe/SkeletonView/releases/tag/1.2.1)

#### 🙌 New

- You can set the corner radius multiline elements (thanks @B4V4-G)
- Save view state when skeleton appears and recovery when it is hidden (@juanpe)

#### 🩹 Bug fixes
- Solved issue [#51](https://github.com/Juanpe/SkeletonView/issues/51). Support inspectable properties when using Carthage. (thanks @eduardbosch)

## 📦 [On TV (1.2)](https://github.com/Juanpe/SkeletonView/releases/tag/1.2)

#### 🙌 New
- Now ```SkeletonView``` is **tvOS** compatible! 🎉.  (thanks @mihai8804858)

#### 🩹 Bug fixes
- Solved issue [#46](https://github.com/Juanpe/SkeletonView/issues/46). It crashes the application when tap on it, didSelect called and crash.


## 📦 [Hotfix (1.1.1)](https://github.com/Juanpe/SkeletonView/releases/tag/1.1.1)

#### 🩹 Bug fixes
- Now yes, solved issue [#39](https://github.com/Juanpe/SkeletonView/issues/39)

## 📦 [Needed (1.1)](https://github.com/Juanpe/SkeletonView/releases/tag/1.1)

#### 🙌 New
- Now ```SkeletonView```supports **UICollectionViews**! 🎉.  (thanks @Renatdz)

#### 🩹 Bug fixes
- Solved issue [#39](https://github.com/Juanpe/SkeletonView/issues/39). Gradient animation did not work when app becomes active.


## 📦 [Resizable (1.0.5)](https://github.com/Juanpe/SkeletonView/releases/tag/1.0.5)

#### 🙌 New
- Now you can use table views with resizable cells.

#### 🩹 Bug fixes
- Solved issues.
 [#17](https://github.com/Juanpe/SkeletonView/issues/17),
 [#30](https://github.com/Juanpe/SkeletonView/issues/30),
 [#34](https://github.com/Juanpe/SkeletonView/issues/34).

## 📦 [Filled or not (1.0.4)](https://github.com/Juanpe/SkeletonView/releases/tag/1.0.4)

#### 🙌 New
- You can set the filling percent of the last line in multiline elements (thanks @jontelang!)

#### 🩹 Bug fixes
- Solved issue [#14](https://github.com/Juanpe/SkeletonView/issues/14). You could edit text views with skeleton active.

## 📦 [In all directions (1.0.3)](https://github.com/Juanpe/SkeletonView/releases/tag/1.0.3)

#### 🙌 New
- Create ```SkeletonAnimationBuilder```, to facilitate the creation of layer animations.
```GradientDirection``` enum.

## 📦 [Retro (1.0.2)](https://github.com/Juanpe/SkeletonView/releases/tag/1.0.2)

#### 🙌 New
- Change some private keywords, to be Swift 3 compatible

## 📦 [Early bird bug (1.0.1)](https://github.com/Juanpe/SkeletonView/releases/tag/1.0.2)

#### 🩹 Bug fixes
- It was not removing the skeleton layer

## 📦 [Starter (1.0)](https://github.com/Juanpe/SkeletonView/releases/tag/1.0)

- First release
