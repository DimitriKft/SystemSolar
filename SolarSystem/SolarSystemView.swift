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

    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            ZStack {
                // Sun
                Circle().fill(Color.orange)
                    .frame(width: geometry.size.width * 0.05, height: geometry.size.width * 0.05)
                    .position(center)
                
                // Planets with orbits and their moons
                ForEach(Planet.allCases, id: \.self) { planet in
                    let orbitFactor: CGFloat = (CGFloat(planet.rawValue) + 1) * 0.12
                    let orbitRadius = orbitFactor * geometry.size.width / 2
                    
                    PlanetOrbitView(center: center, orbitRadius: orbitRadius, planet: planet)
                }
            }
            .scaleEffect(zoomScale)
            .offset(offset)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        self.zoomScale = value.magnitude
                    }
                    .simultaneously(with: DragGesture()
                        .onChanged { value in
                            self.offset = value.translation
                        }
                    )
            )
        }
        .edgesIgnoringSafeArea(.all)
        .padding(10)
    }
}

struct PlanetOrbitView: View {
    let center: CGPoint
    let orbitRadius: CGFloat
    let planet: Planet

    @State private var rotation = Angle(degrees: 0)

    var body: some View {
        let planetSize: CGFloat = orbitRadius * 0.05

        return ZStack {
            // Orbital path for planet
            Circle()
                .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                .frame(width: orbitRadius * 2, height: orbitRadius * 2)
                .position(center)
            
            // Planet and its moons
            PlanetView(orbitRadius: orbitRadius, planet: planet)
                .rotationEffect(rotation, anchor: .center)
                .onAppear {
                    withAnimation(Animation.linear(duration: Double(planet.rawValue + 10)).repeatForever(autoreverses: false)) {
                        rotation = Angle(degrees: 360)
                    }
                }
        }
    }
}

struct PlanetView: View {
    let orbitRadius: CGFloat
    let planet: Planet

    var body: some View {
        let planetSize: CGFloat = orbitRadius * 0.05

        return ZStack {
            // Planet itself
            Circle()
                .fill(planet.color)
                .frame(width: planetSize, height: planetSize)
            
            // Moons and their orbits
            ForEach(planet.moons, id: \.self) { moon in
                MoonOrbitView(planetSize: planetSize, moon: moon)
            }
        }
        .offset(x: orbitRadius)
    }
}

struct MoonOrbitView: View {
    let planetSize: CGFloat
    let moon: Moon
    
    @State private var moonRotation = Angle(degrees: 0)
    
    var body: some View {
        let moonSize = planetSize * moon.sizeFactor
        let moonOrbitRadius = moon.orbitRadiusFactor * planetSize
        
        return ZStack {
            // Orbital path for moon
            Circle()
                .stroke(Color.gray.opacity(0.6), lineWidth: 0.5)
                .frame(width: moonOrbitRadius * 2, height: moonOrbitRadius * 2)
            
            // Moon itself
            Circle()
                .fill(moon.color)
                .frame(width: moonSize, height: moonSize)
                .offset(x: moonOrbitRadius)
                .rotationEffect(moonRotation, anchor: .center)
                .onAppear {
                    withAnimation(Animation.linear(duration: 27.3).repeatForever(autoreverses: false)) {
                        moonRotation = Angle(degrees: 360)
                    }
                }
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
        case .earth:
            return [.moon]
        case .mars:
            return [.phobos, .deimos]
        default:
            return []
        }
    }
}

enum Moon {
    case moon, phobos, deimos

    var color: Color {
        switch self {
        case .moon: return .gray
        case .phobos, .deimos: return .gray
        }
    }

    var sizeFactor: CGFloat {
        switch self {
        case .moon: return 0.5
        case .phobos, .deimos: return 0.3
        }
    }

    var orbitRadiusFactor: CGFloat {
        switch self {
        case .moon: return 1.5
        case .phobos: return 1.2
        case .deimos: return 1.8
        }
    }
}

struct SolarSystemView_Previews: PreviewProvider {
    static var previews: some View {
        SolarSystemView()
    }
}
