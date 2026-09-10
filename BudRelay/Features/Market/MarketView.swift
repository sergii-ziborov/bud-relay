import SwiftUI

struct MarketView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        VStack(spacing: 10) {
            HUDBar()
            ScreenHeader(title: "Market", subtitle: "Local seeds, local hands") { model.goHome() }
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ordersBoard
                    basket
                    seedShelf
                    supplyShelf
                    decorShelf
                }
                .padding(.bottom, 8)
            }
            HubNav(selected: .market)
        }
        .padding(.horizontal, 14)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .contentColumn()
    }

    // MARK: - Orders

    private var ordersBoard: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Bouquet Orders")
                    .font(Typography.display(22))
                    .foregroundStyle(Palette.cream)
                Spacer()
                Text("Help our neighbours")
                    .font(Typography.small)
                    .foregroundStyle(Palette.cream.opacity(0.8))
            }
            ForEach(Array(model.activeOrders.enumerated()), id: \.offset) { slot, order in
                orderRow(order, slot: slot)
            }
            Text("Flowers bring people together")
                .font(Typography.small)
                .foregroundStyle(Palette.cream.opacity(0.8))
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 0.16, green: 0.20, blue: 0.18))
                .overlay { RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Palette.wood, lineWidth: 5) }
                .overlay { RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Palette.woodDark, lineWidth: 1.5) }
                .shadow(color: .black.opacity(0.3), radius: 6, y: 4)
        }
    }

    private func orderRow(_ order: Order, slot: Int) -> some View {
        let ready = model.progress.canFulfil(order)
        return HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(order.name)
                    .font(Typography.body)
                    .foregroundStyle(Palette.ink)
                Text("for \(order.from)")
                    .font(Typography.small)
                    .foregroundStyle(Palette.inkSoft)
                HStack(spacing: 8) {
                    ForEach(order.needsList, id: \.0) { kind, count in
                        HStack(spacing: 2) {
                            FlowerIcon(kind: kind, size: 20)
                            Text("\(min(model.progress.flowers[kind, default: 0], count))/\(count)")
                                .font(Typography.small)
                                .foregroundStyle(model.progress.flowers[kind, default: 0] >= count ? Palette.mossDark : Palette.inkSoft)
                                .monospacedDigit()
                        }
                    }
                }
            }
            Spacer()
            VStack(spacing: 4) {
                HStack(spacing: 3) {
                    Image(systemName: "dollarsign.circle.fill").foregroundStyle(Palette.gold)
                    Text("\(order.coins)")
                        .foregroundStyle(Palette.ink)
                        .monospacedDigit()
                }
                .font(Typography.caption)
                if let decor = order.decor {
                    HStack(spacing: 3) {
                        Image(systemName: decor.symbol)
                        Text(decor.name)
                    }
                    .font(Typography.small)
                    .foregroundStyle(Palette.inkSoft)
                }
                Button {
                    model.fulfil(orderSlot: slot)
                } label: {
                    Text("Deliver")
                        .font(Typography.caption)
                        .foregroundStyle(.white)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 12)
                        .background(Capsule().fill(ready ? Palette.moss : Palette.stone))
                }
                .buttonStyle(PressStyle())
                .disabled(!ready)
                .accessibilityIdentifier("order-deliver-\(slot)")
            }
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Palette.paper)
        }
    }

    // MARK: - Basket

    private var basket: some View {
        let owned = FlowerKind.allCases.filter { model.progress.flowers[$0, default: 0] > 0 }
        return shelf(title: "Your Basket", note: owned.isEmpty ? "Relays of ×3, ×5, and ×8 earn flowers." : "Sell spares, or keep them for orders and the garden.") {
            if !owned.isEmpty {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(owned) { kind in
                        VStack(spacing: 3) {
                            FlowerIcon(kind: kind, size: 34, variant: model.progress.variant(for: kind))
                            Text("\(kind.name) ×\(model.progress.flowers[kind, default: 0])")
                                .font(Typography.small)
                                .foregroundStyle(Palette.ink)
                            Button {
                                model.sell(kind)
                            } label: {
                                Text("Sell 1 · \(kind.value)")
                                    .font(Typography.small)
                                    .foregroundStyle(Palette.ink)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .background(Capsule().fill(Palette.paperDark))
                            }
                            .buttonStyle(PressStyle())
                        }
                    }
                }
            }
        }
    }

    // MARK: - Shelves

    private var seedShelf: some View {
        shelf(title: "Seed Packets", note: "Swap a card in your hand during a level.") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(FlowerKind.allCases.filter { model.progress.isUnlocked($0) }) { kind in
                    let price = MarketCatalog.seedPrice(kind)
                    productCard(title: kind.name, owned: model.progress.seeds[kind, default: 0], price: price, id: "seed-\(kind.rawValue)") {
                        FlowerView(kind: kind, stage: .bud, variant: model.progress.variant(for: kind))
                            .frame(width: 36, height: 36)
                    } action: {
                        model.buySeed(kind)
                    }
                }
            }
        }
    }

    private var supplyShelf: some View {
        shelf(title: "Supplies", note: "Tools never cost a turn. Compost, mulch, and fertilizer work the soil.") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(Tool.allCases) { tool in
                    productCard(title: tool.name, owned: model.progress.supplies[tool, default: 0], price: tool.price, id: "supply-\(tool.rawValue)") {
                        Image(systemName: tool.symbol)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Palette.moss)
                            .frame(width: 36, height: 36)
                    } action: {
                        model.buySupply(tool)
                    }
                }
            }
        }
    }

    private var decorShelf: some View {
        shelf(title: "Garden Decor", note: "Some pieces are only earned: the compost bin, bee hotel, rain barrel, herb spiral, and sundial.") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(MarketCatalog.decorForSale) { decor in
                    productCard(title: decor.name, owned: model.progress.garden.inventory[decor, default: 0], price: decor.price ?? 0, id: "decor-\(decor.rawValue)") {
                        DecorTile(decor: decor)
                            .frame(width: 36, height: 36)
                    } action: {
                        model.buyDecor(decor)
                    }
                }
            }
        }
    }

    private func shelf<Content: View>(title: String, note: String, @ViewBuilder content: () -> Content) -> some View {
        WoodPanel(cornerRadius: 16, padding: 10) {
            VStack(spacing: 8) {
                HStack {
                    SignTitle(text: title, size: 20)
                    Spacer()
                }
                content()
                Text(note)
                    .font(Typography.small)
                    .foregroundStyle(Palette.cream.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func productCard<Icon: View>(title: String, owned: Int, price: Int, id: String, @ViewBuilder icon: () -> Icon, action: @escaping () -> Void) -> some View {
        let affordable = model.progress.coins >= price
        return VStack(spacing: 4) {
            icon()
            Text(title)
                .font(Typography.small)
                .foregroundStyle(Palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text("owned \(owned)")
                .font(Typography.small)
                .foregroundStyle(Palette.inkSoft)
            Button(action: action) {
                HStack(spacing: 3) {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("\(price)")
                        .monospacedDigit()
                }
                .font(Typography.small)
                .foregroundStyle(.white)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Capsule().fill(affordable ? Palette.moss : Palette.stone))
            }
            .buttonStyle(PressStyle())
            .disabled(!affordable)
            .accessibilityIdentifier("buy-\(id)")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Palette.paper)
                .overlay { RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(Palette.woodDark.opacity(0.25), lineWidth: 1) }
        }
    }
}
