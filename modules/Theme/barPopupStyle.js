.pragma library
.import "./userTheme.js" as User

// 各种弹出层尺寸转发。
// 真正常改的值都在 `userTheme.js` 里的 `popup` 对象，这里只保留一个统一出口。

var panel = User.popup
