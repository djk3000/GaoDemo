//
//  ContentView.swift
//  GaoDemo
//
//  Created by 邓璟琨 on 2023/2/6.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State var searchText: String = ""
    let controller: MapViewController = MapViewController.instance
    @StateObject var vm: GaoViewModel = GaoViewModel()
    @State private var selectedPOI: String?
    
    @State var startingOffset: CGFloat = UIScreen.main.bounds.height * 0.9
    @State var currentOffset: CGFloat = 0.0
    
    @State private var selectedOptionIndex = 0
    
    var body: some View {
        ZStack{
            ZStack {
                MapView(controller: controller)
                
                dropListView
            }
            
            if vm.isShowDetial
            {
                detialView
            }
        }
        .ignoresSafeArea()
    }
}

extension ContentView {
    /**整个列表**/
    var dropListView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .opacity(vm.showDetial ? 0 : 1)
            VStack {
                VStack(alignment: .leading){
                    //拖拽条
                    dropBorder
                    
                    HStack {
                        Text("全部")
                            .bold()
                            .font(.system(size: 14))
                            .padding(.horizontal)
                        Spacer()
                        
                        VStack {
                            Picker(selection: $selectedOptionIndex, label: Text("")) {
                                ForEach(0..<controller.options.count) { index in
                                    Text(controller.options[index])
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        .onChange(of: selectedOptionIndex) { _ in
                            controller.defaultName = controller.options[selectedOptionIndex]
                            vm.changeContent()
                        }
                    }
                    
                    ZStack {
                        ScrollView{
                            ScrollViewReader { scrollViewReader in
                                cityListView
                                    .opacity(controller.showCities ? 1 : 0)
                            }
                        }
                        
                        //详情
                        ScrollView{
                            ScrollViewReader { scrollViewReader in
                                listView
                                    .onChange(of: vm.selectedNamePoi) { newValue in
                                        scrollViewReader.scrollTo(newValue)
                                        self.selectedPOI = newValue?.name
                                    }
                                    .opacity(controller.showCities ? 0 : 1)
                            }
                        }
                    }
                    .frame(height: UIScreen.main.bounds.height * 0.3)
                }
                Spacer()
            }
            
            if vm.showDetial{
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.white)
                        .padding(.leading)
                        .padding(.trailing)
                    
                    VStack {
                        dropBorder
                        
                        DetialView(vm: vm, showDilog: $vm.showDetial)
                        
                        Spacer()
                    }
                }
            }
        }
        .offset(y: startingOffset)
        .offset(y: currentOffset)
        .frame(maxWidth: UIScreen.main.bounds.width)
        .gesture(
            DragGesture()
                .onChanged({ value in
                    if (startingOffset + currentOffset) < UIScreen.main.bounds.height * 0.6 { return }
                    print("onchange current-- \(currentOffset)")
                    print("onchange start-- \(startingOffset)")
                    //                            if currentOffset < 0 { return }
                    withAnimation(.spring()){
                        currentOffset = value.translation.height
                    }
                })
                .onEnded({ value in
                    print("onend -- \(currentOffset)")
                    withAnimation(.spring()){
                        if currentOffset < -100{
                            startingOffset = UIScreen.main.bounds.height * 0.6
                            print("上拉")
                        }
                        if currentOffset > 100 {
                            startingOffset = UIScreen.main.bounds.height * 0.9
                            print("下滑")
                        }
                        currentOffset = 0
                    }
                })
        )
    }
    
    /**详细列表**/
    var listView: some View {
        ForEach(vm.allPlaces, id: \.self) { poi in
            ZStack{
                Color.white
                    .opacity(0.0001)
                    .onTapGesture {
                        controller.setMapCenter(poi)
                        self.selectedPOI = poi.name
                        vm.showDetial = true
                    }
                
                HStack{
                    VStack (spacing: 5){
                        HStack{
                            Text(poi.name ?? "")
                                .bold()
                                .font(.system(size: 14))
                            
                            Spacer()
                            Text("详情 >")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .opacity(0.8)
                                .padding(.trailing)
                        }
                        HStack{
                            Text(poi.address ?? "")
                                .font(.caption)
                            Spacer()
                        }
                    }
                    .padding(.leading)
                }
                .id(poi)
            }
            .id(poi)
            .padding(.top)
            .padding(.bottom)
        }
    }
    
    //城市列表
    var cityListView: some View {
        ForEach(vm.citiesCenterList, id: \.self) { poi in
            ZStack{
                Color.white
                    .opacity(0.0001)
                    .onTapGesture {
                    }
                
                
                VStack (spacing: 5){
                    HStack{
                        Text(poi.city ?? "")
                            .bold()
                            .font(.system(size: 14))
                        
                        Spacer()
                        Text(poi.count?.description ?? "0")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .opacity(0.8)
                            .padding(.trailing)
                    }
                }
                .padding(.leading)
                
            }
            .id(poi)
            .padding(.top)
            .padding(.bottom)
        }
    }
    
    /**下拉框**/
    var dropBorder: some View {
        HStack {
            Spacer()
            Rectangle()
                .frame(width: 80, height: 10)
                .background(Color.gray)
                .cornerRadius(10)
                .opacity(0.2)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top)
        .padding(.bottom, 2)
    }
    
    /**详细界面**/
    var detialView: some View {
        ZStack{
            Color.gray.opacity(0.4)
                .onTapGesture {
                    vm.isShowDetial = false
                }
            DialogView(vm: vm, showDilog: $vm.isShowDetial)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
