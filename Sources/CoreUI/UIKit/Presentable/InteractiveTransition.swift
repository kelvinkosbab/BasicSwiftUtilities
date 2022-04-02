//
//  InteractiveTransition.swift
//  
//  Copyright © Kozinga. All rights reserved.
//

#if !os(macOS)

import UIKit

// MARK: - InteractiveTransition

public class InteractiveTransition : UIPercentDrivenInteractiveTransition {
    
    // MARK: - Properties
    
    private let interactiveViews: [UIView]
    private let axis: InteractiveTransition.Axis
    private let direction: InteractiveTransition.Direction
    public weak var delegate: InteractiveTransitionDelegate?
    
    private let gestureType: InteractiveTransition.GestureType
    private let contentSize: CGSize?
    private let percentThreshold: CGFloat
    private let velocityThreshold: CGFloat
    
    private(set) var hasStarted: Bool = false
    private var shouldFinish: Bool = false
    private var activeGestureRecognizers: [UIPanGestureRecognizer] = []
    
    // MARK: - Init
    
    public init(interactiveViews: [UIView],
                 axis: InteractiveTransition.Axis,
                 direction: InteractiveTransition.Direction,
                 gestureType: GestureType = .pan,
                 options: [InteractiveTransition.Option] = [],
                 delegate: InteractiveTransitionDelegate? = nil) {
        
        self.interactiveViews = interactiveViews
        self.axis = axis
        self.direction = direction
        self.delegate = delegate
        
        self.gestureType = options.gestureType
        self.contentSize = options.contentSize
        self.percentThreshold = options.percentThreshold
        self.velocityThreshold = options.velocityThreshold
        
        super.init()
        
        // Configure the dismiss interactive gesture recognizer
        for interactiveView in interactiveViews {
            let gestureRecognizer = self.gestureType.createGestureRecognizer(target: self, action: #selector(self.handleGesture(_:)), axis: self.axis, direction: self.direction)
            gestureRecognizer.delegate = self
            interactiveView.isUserInteractionEnabled = true
            interactiveView.addGestureRecognizer(gestureRecognizer)
            self.activeGestureRecognizers.append(gestureRecognizer)
        }
    }
    
    // MARK: - Gestures
    
    @objc private func handleGesture(_ sender: UIPanGestureRecognizer) {
        
        guard let view = sender.view, self.interactiveViews.contains(view) else {
            return
        }
        
        // Convert position to progress
        let translation = sender.translation(in: view)
        let progress = self.calculateProgress(translation: translation, in: view)
        
        // Velocity calculations
        let velocity: CGFloat
        let velocityVector = sender.velocity(in: view)
        switch self.axis {
        case .x:
            velocity = velocityVector.x
        case .y:
            velocity = velocityVector.y
        case .xy:
            velocity = CGFloat(sqrtf(powf(Float(velocityVector.x), 2) + powf(Float(velocityVector.y), 2)))
        }
        
        // Handle the gesture state
        self.handleGestureState(gesture: sender, progress: progress, velocity: velocity)
    }
    
    private func handleGestureState(gesture: UIPanGestureRecognizer, progress: CGFloat, velocity: CGFloat) {
        switch gesture.state {
        case .began:
            self.hasStarted = true
            self.delegate?.interactionDidSurpassThreshold(self)
            self.update(progress)
        case .changed:
            self.shouldFinish = self.calculateShouldFinish(progress: progress, velocity: velocity)
            self.update(progress)
        case .cancelled:
            self.hasStarted = false
            self.cancel()
        case .ended:
            self.hasStarted = false
            self.shouldFinish ? self.finish() : self.cancel()
        default: break
        }
    }
    
    // MARK: - Calculations
    
    private func calculateShouldFinish(progress: CGFloat, velocity: CGFloat) -> Bool {
        if progress > self.percentThreshold {
            return true
        } else if abs(velocity) > self.velocityThreshold {
            return true
        }
        return false
    }
    
    private func calculateProgress(translation: CGPoint, in view: UIView) -> CGFloat {
        let xMovement = (self.direction == .negative ? -translation.x : translation.x) / (self.contentSize?.width ?? view.bounds.width)
        let yMovement = (self.direction == .negative ? -translation.y : translation.y) / (self.contentSize?.height ?? view.bounds.height)
        
        let movement: CGFloat
        switch self.axis {
        case .x:
            movement = xMovement
        case .y:
            movement = yMovement
        case .xy:
            movement = CGFloat(sqrt(pow(Double(xMovement), 2) + pow(Double(yMovement), 2)))
        }
        
        return CGFloat(min(max(Double(movement), 0.0), 1.0))
    }
}

// MARK: - UIGestureRecognizerDelegate

extension InteractiveTransition : UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // gestureRecognizer is the activeGestureRecognizer associated with this interactive transition
        if gestureRecognizer.view == otherGestureRecognizer.view, let scrollView = gestureRecognizer.view as? UIScrollView {
            if self.axis == .y && self.direction == .positive && scrollView.contentOffset.y <= 0 {
                return true
            } else if self.axis == .y && self.direction == .negative && scrollView.contentOffset.y >= scrollView.contentSize.height {
                return true
            } else if self.axis == .x && self.direction == .positive && scrollView.contentOffset.x <= 0 {
                return true
            } else if self.axis == .x && self.direction == .negative && scrollView.contentOffset.x >= scrollView.contentSize.width {
                return true
            }
        }
        return false
    }
}

extension InteractiveTransition {
    
    public enum Axis {
        case x
        case y
        case xy
    }
    
    public enum Direction {
        case negative
        case positive
    }
    
    public enum Option {
        case percent(CGFloat)
        case velocity(CGFloat)
        case contentSize(CGSize)
        case gestureType(InteractiveTransition.GestureType)
        
        static let defaultPercentThreshold: CGFloat = 0.5
        static let defaultVelocityThreshold: CGFloat = 850
    }
    
    public enum GestureType {
        case pan
        case screenEdgePan
        
        public func createGestureRecognizer(target: Any?, action: Selector?, axis: InteractiveTransition.Axis, direction: InteractiveTransition.Direction) -> UIPanGestureRecognizer {
            switch self {
            case .pan:
                return UIPanGestureRecognizer(target: target, action: action)
            case .screenEdgePan:
                let test = UIScreenEdgePanGestureRecognizer(target: target, action: action)
                switch axis {
                case .x:
                    switch direction {
                    case .positive:
                        test.edges = .left
                    case .negative:
                        test.edges = .right
                    }
                case .y:
                    switch direction {
                    case .positive:
                        test.edges = .top
                    case .negative:
                        test.edges = .bottom
                    }
                case .xy:
                    test.edges = .all
                }
                return test
            }
        }
    }
}

// MARK: - Sequence

public extension Sequence where Iterator.Element == InteractiveTransition.Option {
    
    var percentThreshold: CGFloat {
        for option in self {
            switch option {
            case .percent(let threshold):
                return threshold
            default:
                break
            }
        }
        return 0.3
    }
    
    var velocityThreshold: CGFloat {
        for option in self {
            switch option {
            case .velocity(let threshold):
                return threshold
            default:
                break
            }
        }
        return 850
    }
    
    var gestureType: InteractiveTransition.GestureType {
        for option in self {
            switch option {
            case .gestureType(let gestureType):
                return gestureType
            default:
                break
            }
        }
        return .pan
    }
    
    var contentSize: CGSize? {
        for option in self {
            switch option {
            case .contentSize(let size):
                return size
            default:
                break
            }
        }
        return nil
    }
}

#endif
