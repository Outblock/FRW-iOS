//
//  ResizeableView.swift
//
//
//  Created by Jin Kim on 6/13/22.
//

import Foundation
import UIKit

public class ResizableView: UIView {
    // MARK: Public

    override public func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        if let touch = touches.first {
            touchStart = touch.location(in: self)
            currentEdge = {
                if self.bounds.size.width - touchStart.x < Self.edgeSize,
                   self.bounds.size.height - touchStart.y < Self.edgeSize {
                    return .bottomRight
                } else if touchStart.x < Self.edgeSize, touchStart.y < Self.edgeSize {
                    return .topLeft
                } else if self.bounds.size.width - touchStart.x < Self.edgeSize,
                          touchStart.y < Self.edgeSize {
                    return .topRight
                } else if touchStart.x < Self.edgeSize,
                          self.bounds.size.height - touchStart.y < Self.edgeSize {
                    return .bottomLeft
                }
                return .none
            }()
        }
    }

    override public func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            let previous = touch.previousLocation(in: self)

            let originX = frame.origin.x
            let originY = frame.origin.y
            let width = frame.size.width
            let height = frame.size.height

            let deltaWidth = currentPoint.x - previous.x
            let deltaHeight = currentPoint.y - previous.y

            switch currentEdge {
            case .topLeft:
                frame = CGRect(
                    x: originX + deltaWidth,
                    y: originY + deltaHeight,
                    width: width - deltaWidth,
                    height: height - deltaHeight
                )
            case .topRight:
                frame = CGRect(
                    x: originX,
                    y: originY + deltaHeight,
                    width: width + deltaWidth,
                    height: height - deltaHeight
                )
            case .bottomRight:
                frame = CGRect(
                    x: originX,
                    y: originY,
                    width: width + deltaWidth,
                    height: height + deltaHeight
                )
            case .bottomLeft:
                frame = CGRect(
                    x: originX + deltaWidth,
                    y: originY,
                    width: width - deltaWidth,
                    height: height + deltaHeight
                )
            default:
                // Moving
                center = CGPoint(
                    x: center.x + currentPoint.x - touchStart.x,
                    y: center.y + currentPoint.y - touchStart.y
                )
            }
            // If the frame size gets smaller than minimum subview size, we are not able to drag the edge to increase the size
            // Always expose the edge
            if frame.width < minSubviewSize.width + Self.edgeSize {
                frame.size.width = minSubviewSize.width + Self.edgeSize
                frame.origin.x = originX
            }
            if frame.height < minSubviewSize.height + Self.edgeSize {
                frame.size.height = minSubviewSize.height + Self.edgeSize
                frame.origin.y = originY
            }
        }
    }

    override public func touchesEnded(_: Set<UITouch>, with _: UIEvent?) {
        currentEdge = .none
    }

    // MARK: Internal

    enum Edge {
        case topLeft, topRight, bottomLeft, bottomRight, none
    }

    static var edgeSize: CGFloat = 44.0

    var currentEdge: Edge = .none
    var touchStart = CGPoint.zero
    var minSubviewSize: CGSize = .zero

    // MARK: Private

    private typealias `Self` = ResizableView
}
