//
//  FarmWeatherWidgetLiveActivity.swift
//  FarmWeatherWidget
//
//  Created by Michel Pierce on 24/04/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct FarmWeatherWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct FarmWeatherWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FarmWeatherWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension FarmWeatherWidgetAttributes {
    fileprivate static var preview: FarmWeatherWidgetAttributes {
        FarmWeatherWidgetAttributes(name: "World")
    }
}

extension FarmWeatherWidgetAttributes.ContentState {
    fileprivate static var smiley: FarmWeatherWidgetAttributes.ContentState {
        FarmWeatherWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: FarmWeatherWidgetAttributes.ContentState {
         FarmWeatherWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: FarmWeatherWidgetAttributes.preview) {
   FarmWeatherWidgetLiveActivity()
} contentStates: {
    FarmWeatherWidgetAttributes.ContentState.smiley
    FarmWeatherWidgetAttributes.ContentState.starEyes
}
