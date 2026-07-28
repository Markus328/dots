{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.dms.homeModules.dank-material-shell
  ];

  programs.dank-material-shell = {
    enable = true;
    systemd.enable = true;

    dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default;

    settings = {
      acLockTimeout = 300;
      acMonitorTimeout = 180;
      acProfileName = "";
      acSuspendBehavior = 0;
      acSuspendTimeout = 0;
      animationSpeed = 4;
      appLauncherGridColumns = 4;
      appLauncherViewMode = "grid";
      audioInputDevicePins = {};
      audioOutputDevicePins = {};
      barConfigs = [
        {
          autoHide = true;
          autoHideDelay = 1398;
          borderColor = "surfaceText";
          borderEnabled = false;
          borderOpacity = 1;
          borderThickness = 1;
          bottomGap = 0;
          centerWidgets = [
            {
              enabled = true;
              id = "music";
            }
            {
              enabled = true;
              id = "clock";
            }
            {
              enabled = true;
              id = "weather";
            }
          ];
          enabled = true;
          fontScale = 1;
          gothCornerRadiusOverride = false;
          gothCornerRadiusValue = 12;
          gothCornersEnabled = false;
          id = "default";
          innerPadding = 4;
          leftWidgets = [
            "launcherButton"
            "workspaceSwitcher"
            {
              enabled = true;
              focusedWindowCompactMode = false;
              id = "focusedWindow";
            }
          ];
          maximizeDetection = true;
          name = "Main Bar";
          noBackground = false;
          openOnOverview = false;
          popupGapsAuto = true;
          popupGapsManual = 4;
          position = 0;
          rightWidgets = [
            {
              enabled = true;
              id = "idleInhibitor";
            }
            {
              enabled = true;
              id = "systemTray";
            }
            {
              enabled = true;
              id = "cpuUsage";
            }
            {
              enabled = true;
              id = "memUsage";
            }
            {
              enabled = true;
              id = "notificationButton";
            }
            {
              enabled = true;
              id = "controlCenterButton";
            }
          ];
          screenPreferences = ["all"];
          showOnLastDisplay = true;
          spacing = 4;
          squareCorners = true;
          transparency = 0.95;
          visible = true;
          widgetOutlineColor = "primary";
          widgetOutlineEnabled = true;
          widgetOutlineOpacity = 1;
          widgetOutlineThickness = 1;
          widgetTransparency = 1;
        }
      ];
      batteryLockTimeout = 0;
      batteryMonitorTimeout = 0;
      batteryProfileName = "";
      batterySuspendBehavior = 0;
      batterySuspendTimeout = 0;
      bluetoothDevicePins = {
        preferredDevice = "F7:83:CA:AF:66:38";
      };
      blurWallpaperOnOverview = true;
      blurredWallpaperLayer = true;
      brightnessDevicePins = {};
      centeringMode = "index";
      clockCompactMode = false;
      clockDateFormat = "";
      configVersion = 2;
      controlCenterShowAudioIcon = true;
      controlCenterShowBatteryIcon = false;
      controlCenterShowBluetoothIcon = true;
      controlCenterShowBrightnessIcon = false;
      controlCenterShowMicIcon = false;
      controlCenterShowNetworkIcon = true;
      controlCenterShowPrinterIcon = false;
      controlCenterShowVpnIcon = true;
      controlCenterWidgets = [
        {
          enabled = true;
          id = "volumeSlider";
          width = 50;
        }
        {
          enabled = true;
          id = "brightnessSlider";
          width = 50;
        }
        {
          enabled = true;
          id = "wifi";
          width = 50;
        }
        {
          enabled = true;
          id = "bluetooth";
          width = 50;
        }
        {
          enabled = true;
          id = "audioOutput";
          width = 50;
        }
        {
          enabled = true;
          id = "audioInput";
          width = 50;
        }
        {
          enabled = true;
          id = "nightMode";
          width = 50;
        }
        {
          enabled = true;
          id = "darkMode";
          width = 50;
        }
      ];
      cornerRadius = 12;
      currentThemeName = "dynamic";
      customAnimationDuration = 750;
      customPowerActionHibernate = "";
      customPowerActionLock = "";
      customPowerActionLogout = "";
      customPowerActionPowerOff = "";
      customPowerActionReboot = "";
      customPowerActionSuspend = "";
      customThemeFile = "";
      displayNameMode = "system";
      dockAutoHide = true;
      dockBorderColor = "surfaceText";
      dockBorderEnabled = false;
      dockBorderOpacity = 1;
      dockBorderThickness = 1;
      dockBottomGap = 0;
      dockGroupByApp = true;
      dockIconSize = 40;
      dockIndicatorStyle = "circle";
      dockMargin = 0;
      dockOpenOnOverview = false;
      dockPosition = 1;
      dockSpacing = 10;
      dockTransparency = 1;
      dwlShowAllTags = false;
      enableFprint = false;
      enabledGpuPciIds = [];
      fadeToLockEnabled = false;
      fadeToLockGracePeriod = 15;
      focusedWindowCompactMode = false;
      fontFamily = "Inter Variable";
      fontScale = 1;
      fontWeight = 400;
      gtkThemingEnabled = false;
      hideBrightnessSlider = false;
      iconTheme = "System Default";
      keyboardLayoutNameCompactMode = false;
      launchPrefix = lib.getExe pkgs.app2unit;
      launcherLogoBrightness = 0.5;
      launcherLogoColorInvertOnMode = false;
      launcherLogoColorOverride = "primary";
      launcherLogoContrast = 1;
      launcherLogoCustomPath = "";
      launcherLogoMode = "os";
      launcherLogoSizeOffset = 0;
      lockBeforeSuspend = true;
      lockDateFormat = "ddd MMM d";
      lockScreenActiveMonitor = "all";
      lockScreenInactiveColor = "#000000";
      lockScreenShowPowerActions = true;
      loginctlLockIntegration = true;
      matugenScheme = "scheme-tonal-spot";
      matugenTargetMonitor = "";
      maxFprintTries = 15;
      maxWorkspaceIcons = 3;
      mediaSize = 1;
      modalDarkenBackground = true;
      monoFontFamily = "Fira Code";
      networkPreference = "wifi";
      nightModeEnabled = false;
      niriOverviewOverlayEnabled = false;
      notepadFontFamily = "";
      notepadFontSize = 14;
      notepadLastCustomTransparency = 0.7;
      notepadShowLineNumbers = false;
      notepadTransparencyOverride = -1;
      notepadUseMonospace = true;
      notificationOverlayEnabled = false;
      notificationPopupPosition = 0;
      notificationTimeoutCritical = 0;
      notificationTimeoutLow = 5000;
      notificationTimeoutNormal = 5000;
      osdAlwaysShowValue = false;
      osdAudioOutputEnabled = true;
      osdBrightnessEnabled = true;
      osdCapsLockEnabled = true;
      osdIdleInhibitorEnabled = true;
      osdMediaVolumeEnabled = true;
      osdMicMuteEnabled = true;
      osdPosition = 5;
      osdPowerProfileEnabled = false;
      osdVolumeEnabled = true;
      popupTransparency = 1;
      powerActionConfirm = true;
      powerActionHoldDuration = 0.5;
      powerMenuActions = [
        "reboot"
        "logout"
        "poweroff"
        "lock"
        "suspend"
        "restart"
      ];
      powerMenuDefaultAction = "logout";
      powerMenuGridLayout = true;
      preventIdleForMedia = false;
      privacyShowCameraIcon = false;
      privacyShowMicIcon = false;
      privacyShowScreenShareIcon = false;
      qtThemingEnabled = false;
      runUserMatugenTemplates = true;
      runningAppsCompactMode = true;
      runningAppsCurrentWorkspace = false;
      runningAppsGroupByApp = false;
      screenPreferences = {
        wallpaper = ["all"];
      };
      scrollTitleEnabled = true;
      selectedGpuIndex = 0;
      showBattery = true;
      showCapsLockIndicator = true;
      showClipboard = true;
      showClock = true;
      showControlCenterButton = true;
      showCpuTemp = true;
      showCpuUsage = true;
      showDock = true;
      showFocusedWindow = true;
      showGpuTemp = true;
      showLauncherButton = true;
      showMemUsage = true;
      showMusic = true;
      showNotificationButton = true;
      showOccupiedWorkspacesOnly = false;
      showOnLastDisplay = {};
      showPrivacyButton = true;
      showSeconds = true;
      showSystemTray = true;
      showWeather = true;
      showWorkspaceApps = false;
      showWorkspaceIndex = false;
      showWorkspacePadding = false;
      showWorkspaceSwitcher = true;
      sortAppsAlphabetically = false;
      soundNewNotification = true;
      soundPluggedIn = true;
      soundVolumeChanged = true;
      soundsEnabled = true;
      spotlightCloseNiriOverview = false;
      spotlightModalViewMode = "list";
      syncModeWithPortal = true;
      terminalsAlwaysDark = true;
      updaterCustomCommand = "";
      updaterTerminalAdditionalParams = "";
      updaterUseCustomCommand = false;
      use24HourClock = true;
      useAutoLocation = true;
      useFahrenheit = false;
      useSystemSoundTheme = false;
      vpnLastConnected = "";
      wallpaperFillMode = "Fill";
      waveProgressEnabled = true;
      weatherCoordinates = "40.7128,-74.0060";
      weatherEnabled = true;
      weatherLocation = "New York, NY";
      widgetBackgroundColor = "sch";
      widgetColorMode = "default";
      wifiNetworkPins = {};
      workspaceNameIcons = {};
      workspaceScrolling = false;
      workspacesPerMonitor = true;
    };
  };
}
