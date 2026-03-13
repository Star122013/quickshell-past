pragma ComponentBehavior: Bound

import Quickshell

import "../../Theme/theme.js" as Theme
import "../../Theme/barPopupStyle.js" as PopupStyle
import "barUtils.js" as BarUtils

Scope {
    id: root

    required property var barState

    function closeAllPopups() {
        root.barState.mediaMenuOpen = false;
        root.barState.controlHubOpen = false;
        root.barState.trayMenuOpen = false;
        root.barState.systemStatusMenuOpen = false;
        root.barState.avatarSubmenuOpen = false;
        root.barState.avatarSubmenuSection = "";
        root.barState.avatarMenuOpen = false;
    }

    function setControlHubSection(screenModel, section) {
        if (!screenModel)
            return;
        root.barState.controlHubSection = section;
        root.barState.controlHubWidth = BarUtils.controlHubWidthFor(section, PopupStyle);
        root.barState.controlHubHeight = BarUtils.controlHubHeightFor(section, PopupStyle);
        root.barState.controlHubX = BarUtils.controlHubLeft(screenModel.width, root.barState.controlHubWidth, Theme.outerGap);
        root.barState.controlHubY = Theme.popupTopMargin;
    }

    function openControlHub(screenModel, section) {
        var wasOpen = root.barState.controlHubOpen && root.barState.controlHubSection === section && root.barState.popupScreen === screenModel;
        root.closeAllPopups();
        if (wasOpen)
            return;
        root.barState.popupScreen = screenModel;
        root.setControlHubSection(screenModel, section);
        root.barState.controlHubOpen = true;
    }
}
