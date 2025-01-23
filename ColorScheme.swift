import Foundation
import SwiftUI

public protocol ColorScheme {
  var primaryBackgroundColor: Color { get set }
  var secondaryBackgroundColor: Color { get set }
}

public struct ClassicDark: ColorScheme {
    public var primaryBackgroundColor: Color = .black
    public var secondaryBackgroundColor: Color = .darkGray
}

public struct ClassicLight: ColorScheme {
    public var primaryBackgroundColor: Color = .offWhite
    public var secondaryBackgroundColor: Color = .white
}

extension Color {
    static let darkGray = Color(red: 28/255, green: 28/255, blue: 30/255)
    //static let offWhite = Color(red: 242/255, green: 241/255, blue: 246/255)
}
