//
//  ScrollViewerView.swift
//  SwiftUI_Learn
//
//  Created by 邓璟琨 on 2023/3/1.
//

import SwiftUI

struct ScrollViewerView: View {
    let controller: MapViewController = MapViewController.instance
    
    @State var topSafeArea: CGFloat = 0
    @State var isShowTitle: Bool = false
    @State var height: Double = 0.0
    
    var scrollDetection: some View{
        GeometryReader { proxy in
            //            Text("\(proxy.frame(in: .named("scroll")).minY)")
            ZStack{
                Color.clear.preference(key: ScrollPrefernceKey.self, value: proxy.frame(in: .named("scroll")).minY)
                    .allowsHitTesting(false)
            }
        }
        .onPreferenceChange(ScrollPrefernceKey.self, perform: { value in
            //            withAnimation(.easeInOut) {
            print(value)
            print(UIScreen.main.bounds.size.height * 0.7 - topSafeArea)
            if value < -(UIScreen.main.bounds.size.height * 0.7 - topSafeArea) {
                print(true)
                isShowTitle = true
            }else{
                print(false)
                isShowTitle = false
            }
            //            }
        })
    }
    
    var body: some View {
        ZStack {
            ZStack {
                GeometryReader { proxy in
                    
                    ScrollView {
                        ZStack {
                            VStack{
                                MapView(controller: controller)
                                    .frame(width: UIScreen.main.bounds.size.width , height: UIScreen.main.bounds.size.height * 0.7)
                                Spacer()
                            }
                            
                            
                            VStack {
                                //                            ZStack {
                                //                                Color.gray
                                //                                scrollDetection
                                //                            }
                                //                            .frame(height: height)
                                
                                
                                ZStack {
                                    Color.clear
                                    scrollDetection
                                }
                                .frame(height: UIScreen.main.bounds.size.height * 0.7)
                                .allowsHitTesting(false)
                                
                                
                                
                                //                            Spacer(minLength: UIScreen.main.bounds.size.height * 0.7)
                                //                                .allowsTightening(false)
                                
                                ZStack {
                                    Color.red
                                    VStack{
                                        ZStack {
                                            Color.blue
                                            Text("Title")
                                                .frame(height: 100)
                                        }
                                        ForEach(1..<100) { index in
                                            Text("Item \(index)")
                                                .frame(width: UIScreen.main.bounds.size.width)
                                        }
                                    }
                                }
                                .allowsHitTesting(true)
                                
                                //                ZStack {
                                //                    Color.red
                                //                    ScrollView {
                                //                        VStack(spacing: 50) {
                                //                            ForEach(1..<100) { index in
                                //                                Text("Item \(index)")
                                //                                    .frame(width: UIScreen.main.bounds.size.width)
                                //                            }
                                //                        }
                                //                    }
                                //                }
                                //                .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                            }
                        }
                    } 
                    
                    .onAppear {
                        topSafeArea = proxy.safeAreaInsets.top
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
                //                .offset(y: (UIScreen.main.bounds.size.height * 0.7))
                
                VStack {
                    ZStack {
                        Color.green
                        Text("Title")
                    }
                    .frame(height: 100)
                    Spacer()
                }
                .opacity(isShowTitle ? 1 : 0)
            }
            GeometryReader { proxy in
                VStack {
                    Color.white
                        .frame(height: proxy.safeAreaInsets.top)
                        .ignoresSafeArea()
                    Spacer()
                }
            }
        }
    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct ScrollViewerView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollViewerView()
    }
}

struct ScrollPrefernceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
