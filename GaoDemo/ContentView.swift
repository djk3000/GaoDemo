//
//  ContentView.swift
//  GaoDemo
//
//  Created by 邓璟琨 on 2023/2/6.
//

import SwiftUI

struct ContentView: View {
    @State var searchText: String = ""
    @State var comfirmText: String = "希尔顿酒店"
    let controller: MapViewController = MapViewController.instance
    @StateObject var vm: GaoViewModel = GaoViewModel()
    @State private var selectedPOI: String?
    
    var body: some View {
        ZStack{
            ZStack {
                MapView(controller: controller)
                
                VStack {
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.white)
                            .opacity(vm.showDetial ? 0 : 1)
                        
                        VStack(alignment: .leading){
                            Text("全部")
                                .bold()
                                .font(.system(size: 14))
                                .padding()
                            
                            ZStack {
                                //详情
                                ScrollView{
                                    ScrollViewReader { scrollViewReader in
                                        listView
                                            .onChange(of: vm.selectedNamePoi) { newValue in
                                                scrollViewReader.scrollTo(newValue)
                                                self.selectedPOI = newValue?.name
                                            }
                                    }
                                }
                            }
                        }
                        
                        if vm.showDetial{
                            ZStack {
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(.white)
                                    .padding(.leading)
                                    .padding(.trailing)
                                
                                DetailView(vm: vm, showDilog: $vm.showDetial)
                            }
                        }
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width)
                    .frame(height: UIScreen.main.bounds.height / 2.5)
                }
                
                //                    .onAppear {
                //                        UIScrollView.appearance().isPagingEnabled = true
                //                    }
            }
            
            
            if vm.isShowDetail
            {
                Color.gray.opacity(0.4)
                    .onTapGesture {
                        vm.isShowDetail = false
                    }
                DialogView(vm: vm, showDilog: $vm.isShowDetail)
            }
            
            
        }
        .ignoresSafeArea()
    }
}

extension ContentView {
    var listView: some View {
        ForEach(vm.allHotal, id: \.self) { poi in
            ZStack{
                Color.white
                    .opacity(0.0001)
                    .onTapGesture {
                        controller.setMapCenter(poi)
                        self.selectedPOI = poi.name
                        vm.showDetial = true
                    }
                
                HStack{
                    //                    AsyncImage(url: URL(string: poi.image!)) { image in
                    //                        image
                    //                            .resizable()
                    //                            .scaledToFit()
                    //
                    //                    } placeholder: {
                    //                        Color.gray
                    //                    }
                    //                    .frame(width: 50, height: 50)
                    
                    //                    ZStack{
                    //                        Color.blue
                    //                            .opacity(self.selectedPOI == poi.name ? 1 : 0)
                    //                            .cornerRadius(2)
                    
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
                    //                    }
                }
                .id(poi)
                //                .foregroundColor(self.selectedPOI == poi.name ? Color.white : .black)
            }
            .id(poi)
            .padding(.top)
            .padding(.bottom)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
