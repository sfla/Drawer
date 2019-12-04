import Foundation

protocol Contained:class{
    var currentNotch:Notch { get set }
    var supportedNotches:[Notch] { get set }
}
