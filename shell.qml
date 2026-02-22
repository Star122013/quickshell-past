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

  WifiService {
    id: wifi
  }

  Bar {
    niri: niri
    notifications: notifications
    stats: stats
    audio: audio
    wifi: wifi
  }
}
