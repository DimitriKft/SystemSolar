//
//  ContentView.swift
//  SolarSystem
//
//  Created by dimitri on 24/10/2023.
//

import SwiftUI

struct SolarSystemView: View {
    @State private var zoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @GestureState private var gestureOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let sunRadius: CGFloat = geometry.size.width * 0.05
            
            ZStack {
                Circle().fill(Color.orange).frame(width: sunRadius * 2, height: sunRadius * 2)
                
                ForEach(Planet.allCases, id: \.self) { planet in
                    let orbitFactor: CGFloat = (CGFloat(planet.rawValue) + 1) * 0.12
                    let orbitRadius = orbitFactor * geometry.size.width / 2
                    
                    Path { path in
                        path.addArc(center: center, radius: orbitRadius, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
                    }.stroke(Color.gray.opacity(0.6))
                    
                    PlanetView(position: center, radius: orbitRadius, planet: planet)
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
                    .simultaneously(with: DragGesture()
                        .updating($gestureOffset) { value, state, _ in
                            state = value.translation
                        }
                        .onEnded { value in
                            self.offset.width += value.translation.width
                            self.offset.height += value.translation.height
                        }
                    )
            )
            .edgesIgnoringSafeArea(.all)
        }.padding(10)
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
}

struct PlanetView: View {
    let position: CGPoint
    let radius: CGFloat
    let planet: Planet
    
    @State private var rotation = Angle(degrees: 0)
    
    var body: some View {
        let planetSize: CGFloat = radius * 0.05
        
        return ZStack {
            Circle()
                .fill(planet.color)
                .frame(width: planetSize, height: planetSize)
            
            if planet == .earth {
                MoonView(planetRadius: planetSize, orbitRadius: planetSize * 1.5)
            }
        }
        .offset(x: radius)
        .rotationEffect(rotation, anchor: .center)
        .onAppear {
            withAnimation(Animation.linear(duration: Double(planet.rawValue + 10)).repeatForever(autoreverses: false)) {
                rotation = Angle(degrees: 360)
            }
        }
        .position(position)
    }
}

struct MoonView: View {
    let planetRadius: CGFloat
    let orbitRadius: CGFloat
    
    @State private var rotation = Angle(degrees: 0)
    
    var body: some View {
        let moonSize = planetRadius * 0.5
        
        return Circle()
            .fill(Color.gray)
            .frame(width: moonSize, height: moonSize)
            .offset(x: orbitRadius)
            .rotationEffect(rotation, anchor: .center)
            .onAppear {
                withAnimation(Animation.linear(duration: 27.3).repeatForever(autoreverses: false)) {
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
