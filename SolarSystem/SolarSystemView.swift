//
//  ContentView.swift
//  SolarSystem
//
//  Created by dimitri on 24/10/2023.
//
import SwiftUI

struct SolarSystemView: View {
    @State private var zoomScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    @GestureState private var gestureOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let sunRadius: CGFloat = geometry.size.width * 0.05

            ZStack {
                // Solar System Content
                Circle().fill(Color.orange).frame(width: sunRadius * 2, height: sunRadius * 2) // Sun

                ForEach(Planet.allCases, id: \.self) { planet in
                    let orbitFactor: CGFloat = (CGFloat(planet.rawValue) + 1) * 0.12
                    let orbitRadius = orbitFactor * geometry.size.width / 2

                    Path { path in
                        path.addArc(center: center, radius: orbitRadius, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
                    }.stroke(Color.gray.opacity(0.6))
                    
                    PlanetView(center: center, orbitRadius: orbitRadius, planet: planet)
                }

            }
            .scaleEffect(zoomScale * gestureZoomScale)
            .offset(x: offset.width + gestureOffset.width, y: offset.height + gestureOffset.height)
            .gesture(
                MagnificationGesture()
                    .updating($gestureZoomScale) { currentState, gestureState, _ in
                        gestureState = currentState
                    }
                    .onEnded { finalState in
                        self.zoomScale *= finalState
                    }
            )
            .gesture(
                DragGesture()
                    .updating($gestureOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        self.offset.width += value.translation.width
                        self.offset.height += value.translation.height
                    }
            )
        }
    }
}

enum Planet: Int, CaseIterable {
    case mercury, venus, earth, mars, jupiter, saturn, uranus, neptune

    var color: Color {
        switch self {
        case .mercury: return .gray
        case .venus: return .yellow
        case .earth: return .blue
        case .mars: return .red
        case .jupiter: return .orange
        case .saturn: return .yellow
        case .uranus: return .green
        case .neptune: return .blue
        }
    }
    
    var moons: [Moon] {
        switch self {
        case .earth: return [.moon]
        case .mars: return [.phobos, .deimos]
        default: return []
        }
    }
}

enum Moon: String, CaseIterable {
    case moon, phobos, deimos

    var rotationDuration: Double {
        switch self {
        case .moon: return 27.3
        case .phobos: return 7.66
        case .deimos: return 30.3
        }
    }

    var color: Color {
        switch self {
        case .moon: return .gray
        case .phobos: return .red
        case .deimos: return .brown
        }
    }
    
    var orbitFactor: CGFloat {
        switch self {
        case .moon: return 0.15
        case .phobos: return 0.08
        case .deimos: return 0.12
        }
    }
}

struct PlanetView: View {
    let center: CGPoint
    let orbitRadius: CGFloat
    let planet: Planet

    @State private var rotation = Angle(degrees: 0)

    var body: some View {
        ZStack {
            Circle()
                .fill(planet.color)
                .frame(width: orbitRadius * 0.05, height: orbitRadius * 0.05)
            ForEach(planet.moons, id: \.self) { moon in
                MoonOrbitView(planetCenter: .zero, orbitRadius: moon.orbitFactor * orbitRadius, moon: moon)
            }
        }
        .position(center)
        .offset(x: orbitRadius, y: 0)
        .rotationEffect(rotation)
        .onAppear {
            withAnimation(Animation.linear(duration: Double(planet.rawValue + 10)).repeatForever(autoreverses: false)) {
                rotation = Angle(degrees: 360)
            }
        }
    }
}

struct MoonOrbitView: View {
    let planetCenter: CGPoint
    let orbitRadius: CGFloat
    let moon: Moon

    @State private var rotation = Angle(degrees: 0)

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.7))
                .frame(width: orbitRadius * 2, height: orbitRadius * 2)

            Circle()
                .fill(moon.color)
                .frame(width: orbitRadius * 0.2, height: orbitRadius * 0.2)
                .offset(x: orbitRadius, y: 0)
                .rotationEffect(rotation)
        }
        .onAppear {
            withAnimation(Animation.linear(duration: moon.rotationDuration).repeatForever(autoreverses: false)) {
                rotation = Angle(degrees: 360)
            }
        }
    }
}

struct SolarSystemView_Previews: PreviewProvider {
    static var previews: some View {
        SolarSystemView()
    }
}
