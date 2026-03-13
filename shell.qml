//@ pragma UseQApplication
import Quickshell
import Quickshell.Services.Notifications

import "./modules/Services"
import "./modules/Bar"

Scope {
  id: root

  NotificationServer {
    id: notifications

    keepOnReload: false

    onNotification: function(notification) {
      notification.tracked = true
    }
  }

  NiriService {
    id: niri
  }

  SystemStatsService {
    id: stats
  }

  AudioService {
    id: audio
  }

  BrightnessService {
    id: brightness
  }

  WifiService {
    id: wifi
  }

  Bar {
    niri: niri
    notifications: notifications
    stats: stats
    audio: audio
    brightness: brightness
    wifi: wifi
  }
}
