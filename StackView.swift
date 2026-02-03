
import SwiftUI

struct StackView: View {
    @Binding var selection: Int
    
    init(selection: Binding<Int>) {
        self._selection = selection
    }
    
    init() {
        self._selection = .constant(0)
    }

    let overflowPadding: CGFloat = 30
    let spacing: CGFloat = 5
    
    @State var scrollDisabled: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(0..<5, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundStyle(.orange)
                                .padding([.top, .bottom], spacing / 2)
                                .frame(height: geo.size.height-overflowPadding)
                                .tag(i)
                                .scrollTransition(.animated(.snappy).threshold(.visible(0.2))) { view, transition in
                                    view
                                        .scaleEffect(transition.isIdentity ? 1 : 0.9)
                                }
                                .scrollTransition(.animated(.interactiveSpring(duration: 0.2)).threshold(.visible(0.2))) { view, transition in
                                    view
                                        .opacity(transition.isIdentity ? 1 : 0)
                                }
                        }
                        
                        // Dummy element used to scroll to the top
                        Rectangle()
                            .frame(height: geo.size.height)
                            .foregroundStyle(.clear)
                            .onScrollVisibilityChange(threshold: 0.7) { isVisible in
                                if isVisible {
                                    scrollDisabled = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        scrollDisabled = false
                                    }
                                    withAnimation(.bouncy(duration: 0.3)) {
                                        proxy.scrollTo(0)
                                    }
                                }
                            }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .scrollIndicators(.hidden)
                .scrollClipDisabled()
                .scrollDisabled(scrollDisabled)
                .onScrollTargetVisibilityChange(idType: Int.self, threshold: 0.6, { identifiers in
                    if let first = identifiers.first {
                        selection = first
                    }
                })
                .frame(height: geo.size.height-overflowPadding)
                .padding([.top, .bottom], overflowPadding)
                .clipShape(Rectangle())
            }
        }
    }
}

struct StackIndicator: View {
    var selection: Int = 0
    let indicatorCount: Int = 5
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                ForEach(0..<indicatorCount, id: \.self) { i in
                    Capsule()
                        .frame(width: geo.size.width, height: selection == i ? 3 * geo.size.width : geo.size.width)
                        .animation(.snappy(duration: 0.4, extraBounce: 0.4), value: selection)
                        .foregroundStyle(selection == i ? Color.blue : Color.gray.opacity(0.5))
                }
                Spacer()
            }
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: selection)
    }
}

#if DEBUG
struct StackPreview: View {
    @State var selection: Int = 0
    
    var body: some View {
        HStack {
            StackView(selection: $selection)
                .padding(.leading)
            
            StackIndicator(selection: selection)
                .frame(width: 5)
                .padding(.trailing)
        }
        .frame(height: 200)
    }
}
#endif

#Preview {
    StackPreview()
}
