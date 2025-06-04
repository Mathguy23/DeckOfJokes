--- STEAMODDED HEADER
--- MOD_NAME: Deck of Jokes
--- MOD_ID: DeckOfJokes
--- PREFIX: doj
--- MOD_AUTHOR: [mathguy]
--- MOD_DESCRIPTION: Deck of Jokers
--- DEPENDENCIES: [CustomCards]
--- VERSION: 1.1.1b
----------------------------------------------
------------MOD CODE -------------------------

SMODS.Atlas({ key = "decks", atlas_table = "ASSET_ATLAS", path = "decks.png", px = 71, py = 95})

SMODS.Atlas({ key = "sprites", atlas_table = "ASSET_ATLAS", path = "sprites.png", px = 71, py = 95})

function chaos_the_clown_check()
    if G and G.playing_cards then
        local chaoses = 0
        for i = 1, #G.playing_cards do
            local card = G.playing_cards[i]
            if card and card.ability and card.ability.trading and (card.ability.trading.name == "Chaos the Clown") and not card.debuff then
                chaoses = chaoses + 1
            end
        end
        G.GAME.doj_chaoses = G.GAME.doj_chaoses or 0
        if chaoses ~= G.GAME.doj_chaoses then
            local change = chaoses - G.GAME.doj_chaoses
            G.GAME.doj_chaoses = chaoses
            SMODS.change_free_rerolls(change)
            calculate_reroll_cost(true)
        end
        -------------------------
        local debt = 0
        for i = 1, #G.playing_cards do
            local card = G.playing_cards[i]
            if card and card.ability and card.ability.trading and (card.ability.trading.name == "Credit Card") and not card.debuff then
                debt = debt + (card.ability.trading.config.debt or 20)
            end
        end
        G.GAME.doj_debt = G.GAME.doj_debt or 0
        if debt ~= G.GAME.doj_debt then
            local change = debt - G.GAME.doj_debt
            G.GAME.doj_debt = debt
            G.GAME.bankrupt_at = G.GAME.bankrupt_at - change 
        end
        -------------------------
        local astronomer = false
        for i = 1, #G.playing_cards do
            local card = G.playing_cards[i]
            if card and card.ability and card.ability.trading and (card.ability.trading.name == "Astronomer") and not card.debuff then
                astronomer = true
                break
            end
        end
        if G.GAME.doj_has_astronomer == nil then
            G.GAME.doj_has_astronomer = false
        end
        if astronomer ~= G.GAME.doj_has_astronomer then
            G.GAME.doj_has_astronomer = astronomer
            G.E_MANAGER:add_event(Event({func = function()
                for k, v in pairs(G.I.CARD) do
                    if v.set_cost then v:set_cost() end
                end
            return true end }))
        end
        -------------------------
        local extra_interest = 0
        for i = 1, #G.playing_cards do
            local card = G.playing_cards[i]
            if card and card.ability and card.ability.trading and (card.ability.trading.name == "To the Moon") and not card.debuff then
                extra_interest = extra_interest + (card.ability.trading.config.interest or 1)
            end
        end
        G.GAME.doj_extra_interest = G.GAME.doj_extra_interest or 0
        if extra_interest ~= G.GAME.doj_extra_interest then
            local change = extra_interest - G.GAME.doj_extra_interest
            G.GAME.doj_extra_interest = extra_interest
            G.GAME.interest_amount = G.GAME.interest_amount + change 
        end
        -------------------------
    end
end

local old_ability = Card.set_ability 
function Card:set_ability(center, initial, delay_sprites)
    local hand_size1 = not self.debuff and self.ability and self.ability.trading and self.ability.trading.config.doj_hand_size or 0
    local discards1 = not self.debuff and self.ability and self.ability.trading and self.ability.trading.config.doj_discards or 0
    old_ability(self, center, initial, delay_sprites)
    local hand_size2 = not self.debuff and self.ability and self.ability.trading and self.ability.trading.config.doj_hand_size or 0
    local discards2 = not self.debuff and self.ability and self.ability.trading and self.ability.trading.config.doj_discards or 0
    if self.area == G.hand and (G.hand ~= nil) then
        if hand_size1 ~= hand_size2 then
            local change = hand_size2 - hand_size1
            G.hand.config.real_card_limit = (G.hand.config.real_card_limit or G.hand.config.card_limit) + change
            G.hand.config.card_limit = math.max(0, G.hand.config.real_card_limit)
        end
        if discards1 ~= discards2 then
            local change = discards2 - discards1
            ease_discard(math.max(-G.GAME.current_round.discards_left, change))
        end
    end
    if self.ability and self.ability.trading and (self.ability.trading.name == 'To Do List') then
        local _poker_hands = {}
        for k, v in pairs(G.GAME.hands) do
            if v.visible then _poker_hands[#_poker_hands+1] = k end
        end
        local old_hand = self.ability.trading.config.poker_hand
        self.ability.trading.config.poker_hand = nil

        while not self.ability.trading.config.poker_hand do
            self.ability.trading.config.poker_hand = pseudorandom_element(_poker_hands, pseudoseed((self.area and self.area.config.collection) and 'false_to_do' or 'to_do'))
            if self.ability.trading.config.poker_hand == old_hand then self.ability.trading.config.poker_hand = nil end
        end
    end
    chaos_the_clown_check()
end

local old_remove = Card.remove 
function Card:remove()
    old_remove(self)
    chaos_the_clown_check()
end

local old_set_sprites = Card.set_sprites
function Card:set_sprites(_center, _front)
    old_set_sprites(self, _center, _front)
    if self.ability and self.ability.trading and (self.ability.trading.name == "Wee Joker") and not self.doj_weeified then
        self.doj_weeified = true
        self.T.h = self.T.h * 0.7
        self.T.w = self.T.w * 0.7
    elseif not (self.ability and self.ability.trading and (self.ability.trading.name == "Wee Joker")) and self.doj_weeified then
        self.doj_weeified = nil
    end
    if self.ability and self.ability.trading and (self.ability.trading.name == "Photograph") then
        self.children.center.scale.y = self.children.center.scale.y/1.2
    end
    if self.ability and self.ability.trading and (self.ability.trading.name == "Photograph") and not self.doj_photoified then
        self.doj_photoified = true
        self.T.h = self.T.h / 1.2
    elseif not (self.ability and self.ability.trading and (self.ability.trading.name == "Photograph")) and self.doj_photoified then
        self.doj_photoified = nil
    end
    if self.ability and self.ability.trading and (self.ability.trading.name == "Half Joker") then
        self.children.center.scale.y = self.children.center.scale.y/1.7
    end
    if self.ability and self.ability.trading and (self.ability.trading.name == "Half Joker") and not self.doj_halfified then
        self.doj_halfified = true
        self.T.h = self.T.h / 1.7
    elseif not (self.ability and self.ability.trading and (self.ability.trading.name == "Half Joker")) and self.doj_halfified then
        self.doj_halfified = nil
    end
    if self.ability and self.ability.trading and (self.ability.trading.name == "Square Joker") then
        self.children.center.scale.y = self.children.center.scale.x
    end
    if self.ability and self.ability.trading and (self.ability.trading.name == "Square Joker") and not self.doj_squarified then
        self.doj_squarified = true
        self.T.h = self.T.w
    elseif not (self.ability and self.ability.trading and (self.ability.trading.name == "Square Joker")) and self.doj_squarified then
        self.doj_squarified = nil
    end
end

local old_is_suit = Card.is_suit
function Card:is_suit(suit, bypass_debuff, flush_calc)
    local result = old_is_suit(self, suit, bypass_debuff, flush_calc)
    local smearedness = false
    if G.play and G.play.cards and G.play.cards[1] then
        for i = 1, #G.play.cards do
            local card = G.play.cards[i]
            if card and card.ability and card.ability.trading and (card.ability.trading.name == "Smeared Joker") and not card.debuff then
                smearedness = true
                break
            end
        end
    end
    if not result and smearedness then
        if suit == "Hearts" then
            return old_is_suit(self, "Diamonds", bypass_debuff, flush_calc)
        elseif suit == "Diamonds" then
            return old_is_suit(self, "Hearts", bypass_debuff, flush_calc)
        elseif suit == "Clubs" then
            return old_is_suit(self, "Spades", bypass_debuff, flush_calc)
        elseif suit == "Spades" then
            return old_is_suit(self, "Clubs", bypass_debuff, flush_calc)
        end
    end
    return result
end

local old_is_face = Card.is_face
function Card:is_face(from_boss)
    local result = old_is_face(self, from_boss)
    local pareidolianess = false
    if G.play and G.play.cards and G.play.cards[1] then
        for i = 1, #G.play.cards do
            local card = G.play.cards[i]
            if card and card.ability and card.ability.trading and (card.ability.trading.name == "Pareidolia") and not card.debuff then
                pareidolianess = true
                break
            end
        end
    end
    if not result and pareidolianess then
        return true
    end
    return result
end

G.FUNCS.doj_blueprint_compat = function(e)
    if e.config.ref_table.ability.doj_blueprint_compat ~= e.config.ref_table.ability.doj_blueprint_compat_check then 
        if e.config.ref_table.ability.doj_blueprint_compat == 'compatible' then 
          e.config.colour = mix_colours(G.C.GREEN, G.C.JOKER_GREY, 0.8)
        elseif e.config.ref_table.ability.doj_blueprint_compat == 'incompatible' then
          e.config.colour = mix_colours(G.C.RED, G.C.JOKER_GREY, 0.8)
        end
        e.config.ref_table.ability.doj_blueprint_compat_ui = ' '..localize('k_'..e.config.ref_table.ability.doj_blueprint_compat)..' '
        e.config.ref_table.ability.doj_blueprint_compat_check = e.config.ref_table.ability.doj_blueprint_compat
    end
end

function G.UIDEF.doj_sell_buttons(card)
    local sell = nil
    local use = nil
    sell = 
    {n=G.UIT.C, config={align = "cm"}, nodes={
      {n=G.UIT.C, config={ref_table = card, align = "cm", padding = 0.1, r=0.08, minw = 0.75*card.T.w - 0.15, maxw = 0.85*card.T.w, minh = 0.3, hover = true, shadow = true, colour = G.C.GREEN, button = 'doj_sell_card', func = 'doj_can_sell_card'}, nodes={
        {n=G.UIT.C, config={align = "cm"}, nodes={
            {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
              {n=G.UIT.T, config={text = localize('b_sell'),colour = G.C.UI.TEXT_LIGHT, scale = 0.4, shadow = true}},
              {n=G.UIT.T, config={text = localize('$'),colour = G.C.WHITE, scale = 0.4, shadow = true}},
              {n=G.UIT.T, config={ref_table = card, ref_value = 'sell_cost_label',colour = G.C.WHITE, scale = 0.4, shadow = true}}
            }},
          }}
      }}
    }}
    local t = {
        n=G.UIT.ROOT, config = {padding = 0, colour = G.C.CLEAR}, nodes={
        {n=G.UIT.R, config={padding = 0.15, align = 'cl'}, nodes={
            {n=G.UIT.C, config={align = 'cl'}, nodes={
            sell
            }},
        }},
    }}
    return t
end

G.FUNCS.doj_can_sell_card = function(e)
    if e.config.ref_table and not e.config.ref_table.debuff and e.config.ref_table.ability and e.config.ref_table.ability.trading and e.config.ref_table.ability.trading.sellable and not (G.play and #G.play.cards > 0) and not (G.CONTROLLER.locked) and not (G.GAME.STOP_USE and G.GAME.STOP_USE > 0) then 
        e.config.colour = G.C.GREEN
        e.config.button = 'doj_sell_card'
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end

G.FUNCS.doj_sell_card = function(e)
    if G.GAME.blind and G.GAME.blind.boss and not G.GAME.blind.disabled and e.config.ref_table and e.config.ref_table.ability and e.config.ref_table.ability.trading and (e.config.ref_table.ability.trading.name == 'Luchador') then
        G.GAME.blind:disable()
        card_eval_status_text(e.config.ref_table, 'extra', nil, nil, nil, {message = localize('ph_boss_disabled')})
    end
    if e.config.ref_table and e.config.ref_table.ability and e.config.ref_table.ability.trading and (e.config.ref_table.ability.trading.name == 'Invisible Joker') and (e.config.ref_table.ability.trading.config.rounds >= e.config.ref_table.ability.trading.config.rounds_total) then 
        if #G.jokers.cards > 0 then 
            if #G.jokers.cards < G.jokers.config.card_limit then 
                card_eval_status_text(e.config.ref_table, 'extra', nil, nil, nil, {message = localize('k_duplicated_ex')})
                local chosen_joker = pseudorandom_element(G.jokers.cards, pseudoseed('invisible'))
                local card = copy_card(chosen_joker, nil, nil, nil, chosen_joker.edition and chosen_joker.edition.negative)
                if card.ability.invis_rounds then card.ability.invis_rounds = 0 end
                card:add_to_deck()
                G.jokers:emplace(card)
            else
                card_eval_status_text(e.config.ref_table, 'extra', nil, nil, nil, {message = localize('k_no_room_ex')})
            end
        else
            card_eval_status_text(e.config.ref_table, 'extra', nil, nil, nil, {message = localize('k_no_other_jokers')})
        end
    end
    if e.config.ref_table and e.config.ref_table.ability and e.config.ref_table.ability.trading and (e.config.ref_table.ability.trading.name == 'Diet Cola') then 
        G.E_MANAGER:add_event(Event({
            func = (function()
                add_tag(Tag('tag_double'))
                play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
               return true
           end)
        }))
    end
    G.FUNCS.sell_card(e)
end

SMODS.PokerHandPart {
    key = '_flush_four_fingers',
    func = function(hand) 
        local ret = {}
        local has_four_fingers = next(find_joker("Four Fingers"))
        local smearedness = nil
        for i = 1, #hand do
            if hand[i].ability.trading and (hand[i].ability.trading.name == "Four Fingers") and not hand[i].debuff then
                has_four_fingers = true
            end
            if hand[i].ability.trading and (hand[i].ability.trading.name == "Smeared Joker") and not hand[i].debuff then
                smearedness = true
            end
        end
        for i, j in ipairs(SMODS.Suit.obj_buffer) do
            local flush = {}
            for k = 1, #hand do
                if hand[k]:is_suit(j, nil, true) then 
                    table.insert(flush, hand[k])
                elseif smearedness then
                    if (j == "Hearts") and hand[k]:is_suit("Diamonds", nil, true) then
                        table.insert(flush, hand[k])
                    elseif (j == "Diamonds") and hand[k]:is_suit("Hearts", nil, true) then
                        table.insert(flush, hand[k])
                    elseif (j == "Clubs") and hand[k]:is_suit("Spades", nil, true) then
                        table.insert(flush, hand[k])
                    elseif (j == "Spades") and hand[k]:is_suit("Clubs", nil, true) then
                        table.insert(flush, hand[k])
                    end
                end 
            end
            if #flush >= (has_four_fingers and 4 or 5) then
                table.insert(ret, flush)
                return ret
            end
        end
    end,
}

SMODS.PokerHandPart {
    key = '_straight_four_fingers',
    func = function(hand)
        local has_four_fingers = next(find_joker("Four Fingers"))
        local has_shortcut = not not next(find_joker("Shortcut"))
        for i = 1, #hand do
            if hand[i].ability.trading and (hand[i].ability.trading.name == "Four Fingers") and not hand[i].debuff then
                has_four_fingers = true
            end
            if hand[i].ability.trading and (hand[i].ability.trading.name == "Shortcut") and not hand[i].debuff then
                has_shortcut = true
            end
        end
        if G.hand then
            for i = 1, #G.hand.cards do
                if G.hand.cards[i].ability.trading and (G.hand.cards[i].ability.trading.name == "Shortcut") and not G.hand.cards[i].debuff then
                    has_shortcut = true
                end
            end
        end
        return get_straight(hand, has_four_fingers and 4 or 5, has_shortcut)
    end,
}

local old_flush_eval = SMODS.PokerHandParts['_flush'].func
SMODS.PokerHandParts['_flush'].func = function(hand)
    local old_eval = old_flush_eval(hand)
    if not next(old_eval) then
        return SMODS.PokerHandParts['doj__flush_four_fingers'].func(hand)
    else
        return old_eval
    end
end

local old_straight_eval = SMODS.PokerHandParts['_straight'].func
SMODS.PokerHandParts['_straight'].func = function(hand)
    local old_eval = old_straight_eval(hand)
    if not next(old_eval) then
        return SMODS.PokerHandParts['doj__straight_four_fingers'].func(hand)
    else
        return old_eval
    end
end

local old_find_joker = find_joker
function find_joker(name, non_debuff)
    local result = old_find_joker(name, non_debuff)
    if next(result) then
        return result
    end
    if G.playing_cards and (name == "Showman") then
        local showmen = {}
        for i = 1, #G.playing_cards do
            local card = G.playing_cards[i]
            if card and card.ability and card.ability.trading and (card.ability.trading.name == "Showman") and (not card.debuff or non_debuff) then
                table.insert(showmen, card)
            end
        end
        return showmen
    elseif G.playing_cards and (name == "Astronomer") then
        local astronomers = {}
        for i = 1, #G.playing_cards do
            local card = G.playing_cards[i]
            if card and card.ability and card.ability.trading and (card.ability.trading.name == "Astronomer") and (not card.debuff or non_debuff) then
                table.insert(astronomers, card)
            end
        end
        return astronomers
    end
    return {}
end

local old_find_card = SMODS.find_card
function SMODS.find_card(key, count_debuffed)
    local result = old_find_card(key, count_debuffed)
    if next(result) then
        return result
    end
    if G.playing_cards and (key == "j_ring_master") then
        local showmen = {}
        for i = 1, #G.playing_cards do
            local card = G.playing_cards[i]
            if card and card.ability and card.ability.trading and (card.ability.trading.name == "Showman") and (not card.debuff or count_debuffed) then
                table.insert(showmen, card)
            end
        end
        return showmen
    elseif G.playing_cards and (key == "j_astronomer") then
        local astronomers = {}
        for i = 1, #G.playing_cards do
            local card = G.playing_cards[i]
            if card and card.ability and card.ability.trading and (card.ability.trading.name == "Astronomer") and (not card.debuff or count_debuffed) then
                table.insert(astronomers, card)
            end
        end
        return astronomers
    end
    return {}
end

function get_smods_rank_from_id(card)
    local id = card:get_id()
    if id > 0 then
        for i, j in pairs(SMODS.Ranks) do
            if j.id == id then
                return j
            end
        end
    else
        return {}
    end
end

function to_big_talisman(a)
    if to_big then
        return to_big(a)
    else
        return a
    end
end

if pc_add_cross_mod_card then
    pc_add_cross_mod_card {
        key = 'doj_joker',
        card = {
            key = 'doj_joker', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Joker", 
            pos = {x=0,y=0},
            config = {mult = 4}, 
            base = "C_4",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                table.insert(effects, {
                    mult = config_thing.mult,
                    card = blueprint_card or card
                })
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_bloodstone',
        card = {
            key = 'doj_bloodstone', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Bloodstone", 
            pos = {x=0,y=8},
            config = {x_mult = 1.5, odds = 2}, 
            base = "H_5",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.individual and (context.cardarea == G.play) and (card.area == G.play) then
                if context.other_card:is_suit("Hearts") and (pseudorandom('bloodstone') < G.GAME.probabilities.normal/config_thing.odds) then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = context.other_card
                    })
                elseif context.other_card:is_suit("Hearts") then
                    table.insert(effects, {})
                end
            elseif context.is_suit then
                if ((context.is_suit == "Diamonds") and next(find_joker('Smeared Joker'))) or (context.is_suit == "Hearts") then
                    return true
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {G.GAME.probabilities.normal, config_thing.odds, config_thing.x_mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_mime',
        card = {
            key = 'doj_mime', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Mime", 
            pos = {x=4,y=1},
            config = {}, 
            base = "S_K",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.repetition and (card.area == G.play) and (context.cardarea == G.hand) then
                local special_table = {blueprint_card or card}
                if reps_i ~= 1 then
                    for j = 1, #reps[reps_i].cards do
                        table.insert(special_table, reps[reps_i].cards[j])
                    end
                end
                table.insert(effects, {
                    message = localize('k_again_ex'),
                    repetitions = 1,
                    cards = special_table
                })
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
    }

    pc_add_cross_mod_card {
        key = 'doj_matador',
        card = {
            key = 'doj_matador', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Matador", 
            pos = {x=4,y=5},
            config = {dollars = 8}, 
            base = "D_8",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if (context.debuffed_hand and (context.cardarea == G.play)) or (context.playing_card_main) then
                if G.GAME.blind.triggered then 
                    ease_dollars(config_thing.dollars)
                    G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + config_thing.dollars
                    G.E_MANAGER:add_event(Event({func = (function() G.GAME.dollar_buffer = 0; return true end)}))
                    card_eval_status_text(blueprint_card or card, 'jokers', nil, nil, nil, {message = localize('$')..config_thing.dollars, colour = G.C.MONEY})
                    table.insert(effects, {})
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.dollars}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_rocket',
        card = {
            key = 'doj_rocket', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Rocket", 
            pos = {x=8,y=12},
            config = {dollars = 1, mod_dollars = 2}, 
            base = "D_J",
            is_joker = true,
            joker_rarity = 2,
            blueprint_incompat = true,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.end_of_round and (context.cardarea == G.hand) and not context.individual and not context.repetition and not context.blueprint then
                if G.GAME.blind_on_deck == "Boss" then
                    table.insert(effects, {
                        message = localize("k_upgrade_ex"),
                        card = card
                    })
                    config_thing.dollars = config_thing.dollars + config_thing.mod_dollars
                end
                table.insert(effects, {
                    dollars = config_thing.dollars,
                    card = card
                })
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.dollars, config_thing.mod_dollars}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_sixth_sense',
        card = {
            key = 'doj_sixth_sense', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Sixth Sense", 
            pos = {x=8,y=10},
            config = {}, 
            base = "S_6",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.destroying_card then
                if (context.destroying_card ~= card) and (#context.full_hand == 2) and (context.destroying_card:get_id() == 6) and (G.GAME.current_round.hands_played == 0) and (context.cardarea == G.play) then
                    if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        G.E_MANAGER:add_event(Event({
                            trigger = 'before',
                            delay = 0.0,
                            func = (function()
                                    local card_ = create_card('Spectral',G.consumeables, nil, nil, nil, nil, nil, 'sixth')
                                    card_:add_to_deck()
                                    G.consumeables:emplace(card_)
                                    G.GAME.consumeable_buffer = 0
                                return true
                            end)}))
                        card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_plus_spectral'), colour = G.C.SECONDARY_SET.Spectral})
                    end
                    return true
                end
            elseif context.is_face then
                return true
            elseif context.get_id then
                return 6
            elseif context.does_score then
                return true
            end
        end,
    }

    pc_add_cross_mod_card {
        key = 'doj_fibonacci',
        card = {
            key = 'doj_fibonacci', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Fibonacci", 
            pos = {x=1,y=5},
            config = {mult = 8}, 
            base = "C_A",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.individual and (context.cardarea == G.play) and (card.area == G.play) and not context.end_of_round then
                local id = context.other_card:get_id()
                if (id == 2) or (id == 3) or (id == 5) or (id == 8) or (id == 14) then
                    table.insert(effects, {
                        mult = config_thing.mult,
                        card = context.other_card
                    })
                end
            elseif context.get_id then
                return 14
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_chaos',
        card = {
            key = 'doj_chaos', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Chaos the Clown", 
            pos = {x=1,y=0},
            config = {}, 
            base = "D_J",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            return {1}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_dna',
        card = {
            key = 'doj_dna', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "DNA", 
            pos = {x=5,y=10},
            config = {}, 
            base = "S_A",
            is_joker = true,
            joker_rarity = 3,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.before and (#context.full_hand == 2) and (G.GAME.current_round.hands_played == 0) and (context.cardarea == G.play) then
                local other_card = context.full_hand[1]
                if other_card == (blueprint_card or card) then
                    other_card = context.full_hand[2]
                end
                G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                local _card = copy_card(other_card, nil, nil, G.playing_card)
                _card:add_to_deck()
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                table.insert(G.playing_cards, _card)
                G.hand:emplace(_card)
                _card.states.visible = nil

                G.E_MANAGER:add_event(Event({
                    func = function()
                        _card:start_materialize()
                        return true
                    end
                }))
                playing_card_joker_effects({_card})
                card_eval_status_text(blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_copied_ex'), colour = G.C.CHIPS})
            elseif context.does_score then
                return true
            end
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_runner',
        card = {
            key = 'doj_runner', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Runner", 
            pos = {x=3,y=10},
            config = {chips = 0, mod_chips = 15}, 
            base = "S_Q",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.before and ((context.cardarea == G.play) or (context.cardarea == G.hand)) and next(context.poker_hands['Straight']) and not context.blueprint then
                config_thing.chips = config_thing.chips + config_thing.mod_chips
                table.insert(effects, {})
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex'), colour = G.C.CHIPS})
            elseif context.playing_card_main then
                if config_thing.chips ~= 0 then
                    table.insert(effects, {
                        chips = config_thing.chips,
                        card = blueprint_card or card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.chips, config_thing.mod_chips}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_constellation',
        card = {
            key = 'doj_constellation', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Constellation", 
            pos = {x=9,y=10},
            config = {x_mult = 1, mod_x_mult = 0.1}, 
            base = "H_J",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.using_consumeable and (context.using_consumeable.ability.set == "Planet") and not context.blueprint then
                config_thing.x_mult = config_thing.x_mult + config_thing.mod_x_mult
                table.insert(effects, {})
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex'), colour = G.C.FILTER})
            elseif context.playing_card_main then
                if config_thing.x_mult ~= 1 then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mod_x_mult, config_thing.x_mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_mail',
        card = {
            key = 'doj_mail', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Mail-In Rebate", 
            pos = {x=7,y=13},
            config = {dollars = 5}, 
            base = "D_5",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.discard and (context.other_card:get_id() == G.GAME.current_round.mail_card.id) then
                ease_dollars(config_thing.dollars)
                table.insert(effects, {})
                card_eval_status_text(blueprint_card or card, 'extra', nil, nil, nil, {message = localize('$')..config_thing.dollars, colour = G.C.MONEY})
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.dollars, localize(G.GAME.current_round.mail_card.rank, 'ranks')}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_card_sharp',
        card = {
            key = 'doj_card_sharp', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Card Sharp", 
            pos = {x=6,y=11},
            config = {x_mult = 3}, 
            base = "H_3",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main and G.GAME.hands[context.scoring_name] and (G.GAME.hands[context.scoring_name].played_this_round > 1) then
                table.insert(effects, {
                    x_mult = config_thing.x_mult,
                    card = card
                })
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.x_mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_perkeo',
        card = {
            key = 'doj_perkeo', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Perkeo", 
            pos = {x=7,y=8},
            soul_pos = {x=7,y=9},
            config = {}, 
            base = "S_A",
            is_joker = true,
            joker_rarity = 4,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.end_of_round and (context.cardarea == G.hand) and not context.individual and not context.repetition then
                if G.consumeables.cards[1] then
                    G.E_MANAGER:add_event(Event({
                        func = function() 
                            local c_pool = {}
                            for i, j in ipairs(G.consumeables.cards) do
                                local card_ = G.consumeables.cards[i]
                                if card_.ability.consumeable then
                                    c_pool[#c_pool + 1] = card_
                                end
                            end
                            if #c_pool == 0 then
                                return true
                            end
                            local card_ = copy_card(pseudorandom_element(c_pool, pseudoseed('perkeo')), nil)
                            card_.ability.no_perkeo = true
                            card_:set_edition({negative = true}, true)
                            card_:add_to_deck()
                            G.consumeables:emplace(card_) 
                            return true
                        end}))
                    card_eval_status_text(blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_duplicated_ex')})
                    table.insert(effects, {})
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_ticket',
        card = {
            key = 'doj_ticket', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Golden Ticket", 
            pos = {x=5,y=3},
            config = {dollars = 4}, 
            base = "D_4",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.individual and (context.cardarea == G.play) and (card.area == G.play) and not context.end_of_round and (context.other_card.ability.name == "Gold Card") then
                table.insert(effects, {
                    dollars = config_thing.dollars,
                    card = context.other_card
                })
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.dollars}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_golden',
        card = {
            key = 'doj_golden', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Golden Joker", 
            pos = {x=9,y=2},
            config = {dollars = 4}, 
            base = "D_A",
            is_joker = true,
            joker_rarity = 1,
            blueprint_incompat = true,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.end_of_round and (context.cardarea == G.hand) and not context.individual and not context.repetition and not context.blueprint then
                table.insert(effects, {
                    dollars = config_thing.dollars,
                    card = card
                })
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.dollars}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_blueprint',
        card = {
            key = 'doj_blueprint', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Blueprint", 
            pos = {x=0,y=3},
            config = {}, 
            base = "S_K",
            is_joker = true,
            joker_rarity = 3,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_lucky_cat',
        card = {
            key = 'doj_lucky_cat', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Lucky Cat", 
            pos = {x=5,y=14},
            config = {x_mult = 1, mod_x_mult = 0.25}, 
            base = "H_Q",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.individual and not context.blueprint then
                if context.individual and (context.cardarea == G.play) and (card.area == G.play) and not context.blueprint_card then
                    if context.other_card.lucky_trigger then
                        config_thing.x_mult = config_thing.x_mult + config_thing.mod_x_mult
                        table.insert(effects, {
                            extra = {focus = blueprint_card or card, message = localize('k_upgrade_ex'), colour = G.C.MULT},
                            card = blueprint_card or card
                        })
                    end
                end
            elseif context.playing_card_main then
                if config_thing.x_mult ~= 1 then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mod_x_mult, config_thing.x_mult}
        end,
        in_pool = function()
            for kk, vv in pairs(G.playing_cards) do
                if SMODS.has_enhancement(vv, 'm_lucky') then
                    return true
                end
            end
            return false
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_wee',
        card = {
            key = 'doj_wee', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Wee Joker", 
            pos = {x=0,y=0},
            config = {chips = 0, mod_chips = 8}, 
            base = "S_2",
            is_joker = true,
            joker_rarity = 3,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.individual and not context.blueprint then
                if context.individual and (context.cardarea == G.play) and (card.area == G.play) and not context.blueprint_card then
                    if context.other_card:get_id() == 2 then
                        config_thing.chips = config_thing.chips + config_thing.mod_chips
                        table.insert(effects, {
                            extra = {focus = blueprint_card or card, message = localize('k_upgrade_ex'), colour = G.C.CHIPS},
                            card = blueprint_card or card
                        })
                    end
                end
            elseif context.playing_card_main then
                if config_thing.chips ~= 0 then
                    table.insert(effects, {
                        chips = config_thing.chips,
                        card = blueprint_card or card
                    })
                end
            elseif context.get_id then
                return 2
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.chips, config_thing.mod_chips}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_burnt',
        card = {
            key = 'doj_burnt', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Burnt Joker", 
            pos = {x=3,y=7},
            config = {}, 
            base = "S_K",
            is_joker = true,
            joker_rarity = 3,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.pre_discard and (G.GAME.current_round.discards_used <= 0) and not context.hook then
                local text,disp_text = G.FUNCS.get_poker_hand_info(G.hand.highlighted)
                card_eval_status_text(blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex')})
                update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(text, 'poker_hands'),chips = G.GAME.hands[text].chips, mult = G.GAME.hands[text].mult, level=G.GAME.hands[text].level})
                level_up_hand(blueprint_card or card, text, nil, 1)
                update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
                table.insert(effects, {})
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_credit_card',
        card = {
            key = 'doj_credit_card', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Credit Card", 
            pos = {x=5,y=1},
            config = {debt = 20}, 
            base = "D_T",
            is_joker = true,
            joker_rarity = 1,
            blueprint_incompat = true,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.debt}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_vagabond',
        card = {
            key = 'doj_vagabond', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Vagabond", 
            pos = {x=5,y=12},
            config = {dollars = 4}, 
            base = "D_4",
            is_joker = true,
            joker_rarity = 3,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if (to_big_talisman(G.GAME.dollars) <= to_big_talisman(config_thing.dollars)) and (#G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit) then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    G.E_MANAGER:add_event(Event({
                        trigger = 'before',
                        delay = 0.0,
                        func = (function()
                                local card = create_card('Tarot',G.consumeables, nil, nil, nil, nil, nil, 'vag')
                                card:add_to_deck()
                                G.consumeables:emplace(card)
                                G.GAME.consumeable_buffer = 0
                            return true
                        end)}))
                    table.insert(effects, {
                        message = localize('k_plus_tarot'),
                        card = blueprint_card or card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.dollars}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_chicot',
        card = {
            key = 'doj_chicot', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Chicot",
            pos = {x=6,y=8},
            soul_pos = {x=6,y=9},
            config = {}, 
            base = "S_J",
            is_joker = true,
            joker_rarity = 4,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.drawn then
                card.ability.already_drawn = G.GAME.round
                if G.GAME.blind and G.GAME.blind.boss and not G.GAME.blind.disabled then
                    G.E_MANAGER:add_event(Event({func = function()
                        G.E_MANAGER:add_event(Event({func = function()
                            G.GAME.blind:disable()
                            play_sound('timpani')
                            delay(0.4)
                            return true end }))
                        card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('ph_boss_disabled')})
                    return true end }))
                    table.insert(effects, {})
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_luchador',
        card = {
            key = 'doj_luchador', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Luchador", 
            pos = {x=1,y=13},
            config = {}, 
            base = "S_K",
            is_joker = true,
            joker_rarity = 2,
            sellable = true,
            blueprint_incompat = true,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_flower_pot',
        card = {
            key = 'doj_flower_pot', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Flower Pot", 
            pos = {x=0,y=6},
            config = {x_mult = 3}, 
            base = "H_4",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                local suits = {
                    ['Hearts'] = 0,
                    ['Diamonds'] = 0,
                    ['Spades'] = 0,
                    ['Clubs'] = 0
                }
                for i = 1, #context.scoring_hand do
                    if not SMODS.has_any_suit(context.scoring_hand[i]) then
                        if context.scoring_hand[i]:is_suit('Hearts', true) and suits["Hearts"] == 0 then suits["Hearts"] = suits["Hearts"] + 1
                        elseif context.scoring_hand[i]:is_suit('Diamonds', true) and suits["Diamonds"] == 0  then suits["Diamonds"] = suits["Diamonds"] + 1
                        elseif context.scoring_hand[i]:is_suit('Spades', true) and suits["Spades"] == 0  then suits["Spades"] = suits["Spades"] + 1
                        elseif context.scoring_hand[i]:is_suit('Clubs', true) and suits["Clubs"] == 0  then suits["Clubs"] = suits["Clubs"] + 1 end
                    end
                end
                for i = 1, #context.scoring_hand do
                    if SMODS.has_any_suit(context.scoring_hand[i]) then
                        if context.scoring_hand[i]:is_suit('Hearts') and suits["Hearts"] == 0 then suits["Hearts"] = suits["Hearts"] + 1
                        elseif context.scoring_hand[i]:is_suit('Diamonds') and suits["Diamonds"] == 0  then suits["Diamonds"] = suits["Diamonds"] + 1
                        elseif context.scoring_hand[i]:is_suit('Spades') and suits["Spades"] == 0  then suits["Spades"] = suits["Spades"] + 1
                        elseif context.scoring_hand[i]:is_suit('Clubs') and suits["Clubs"] == 0  then suits["Clubs"] = suits["Clubs"] + 1 end
                    end
                end
                if suits["Hearts"] > 0 and
                suits["Diamonds"] > 0 and
                suits["Spades"] > 0 and
                suits["Clubs"] > 0 then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.x_mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_four_fingers',
        card = {
            key = 'doj_four_fingers', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Four Fingers", 
            pos = {x=6,y=6},
            config = {}, 
            base = "S_4",
            is_joker = true,
            joker_rarity = 2,
            blueprint_incompat = true,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.does_score then
                return true
            end
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_hanging_chad',
        card = {
            key = 'doj_hanging_chad', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Hanging Chad", 
            pos = {x=9,y=6},
            config = {retriggers = 2}, 
            base = "S_3",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.repetition and (card.area == G.play) and (context.cardarea == G.play) then
                local special_table = {blueprint_card or card}
                if reps_i ~= 1 then
                    for j = 1, #reps[reps_i].cards do
                        table.insert(special_table, reps[reps_i].cards[j])
                    end
                end
                if context.other_card == context.scoring_hand[1] then
                    table.insert(effects, {
                        message = localize('k_again_ex'),
                        repetitions = config_thing.retriggers,
                        cards = special_table
                    })
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.retriggers}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_stencil',
        card = {
            key = 'doj_stencil', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Joker Stencil", 
            pos = {x=2,y=5},
            config = {x_mult = 1}, 
            base = "H_5",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if config_thing.x_mult >= 1 then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.x_mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_ring_master',
        card = {
            key = 'doj_ring_master', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Showman", 
            pos = {x=6,y=5},
            config = {}, 
            base = "S_7",
            is_joker = true,
            joker_rarity = 2,
            blueprint_incompat = true,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_invisible',
        card = {
            key = 'doj_invisible', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Invisible Joker", 
            pos = {x=1,y=7},
            config = {rounds = 0, rounds_total = 2}, 
            base = "S_2",
            is_joker = true,
            joker_rarity = 3,
            blueprint_incompat = true,
            sellable = true,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.total_end_of_round then
                config_thing.rounds = config_thing.rounds + 1
                card_eval_status_text(blueprint_card or card, 'extra', nil, nil, nil, {message = (config_thing.rounds < config_thing.rounds_total) and (config_thing.rounds..'/'..config_thing.rounds_total) or localize('k_active_ex')})
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.rounds_total, config_thing.rounds}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_triboulet',
        card = {
            key = 'doj_triboulet', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Triboulet", 
            pos = {x=4,y=8},
            soul_pos = {x=4,y=9},
            config = {x_mult = 2}, 
            base = "H_K",
            is_joker = true,
            joker_rarity = 4,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.individual and (context.cardarea == G.play) and (card.area == G.play) and not context.end_of_round then
                local id = context.other_card:get_id()
                if (id == 12) or (id == 13) then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = context.other_card
                    })
                end
            elseif context.get_id then
                return 13
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.x_mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_droll',
        card = {
            key = 'doj_droll', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Droll Joker", 
            pos = {x=6,y=0},
            config = {mult = 10}, 
            base = "C_T",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main or context.playing_card_hand then
                if next(context.poker_hands["Flush"]) then
                    table.insert(effects, {
                        mult = config_thing.mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_jolly',
        card = {
            key = 'doj_jolly', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Jolly Joker", 
            pos = {x=2,y=0},
            config = {mult = 8}, 
            base = "C_8",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if next(context.poker_hands["Pair"]) then
                    table.insert(effects, {
                        mult = config_thing.mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_raised_fist',
        card = {
            key = 'doj_raised_fist', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Raised Fist", 
            pos = {x=8,y=2},
            config = {}, 
            base = "C_5",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.individual and (context.cardarea == G.hand) and (card.area == G.play) and not context.end_of_round and G.hand.cards[1] then
                local card_ = G.hand.cards[1]
                local rank = get_smods_rank_from_id(card_)
                if not next(rank) then
                    rank.nominal = -999
                end
                for i=1, #G.hand.cards do
                    local rank2 = get_smods_rank_from_id(G.hand.cards[i])
                    if next(rank2) then
                        if rank.nominal >= rank2.nominal then 
                            card_ = G.hand.cards[i]
                            rank = rank2
                        end
                    end
                end
                if (rank.nominal ~= -999) and (card_ == context.other_card) then 
                    if context.other_card.debuff then
                        table.insert(effects, {
                            message = localize('k_debuffed'),
                            colour = G.C.RED,
                            card = blueprint_card or self,
                        })
                    else
                        table.insert(effects, {
                            mult = 2*rank.nominal,
                            card = blueprint_card or self,
                        })
                    end
                end
            elseif context.does_score then
                return true
            end
        end,
    }

    pc_add_cross_mod_card {
        key = 'doj_campfire',
        card = {
            key = 'doj_campfire', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Campfire", 
            pos = {x=5,y=15},
            config = {x_mult = 1, mod_x_mult = 0.25}, 
            base = "H_5",
            is_joker = true,
            joker_rarity = 3,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.selling_card and not context.blueprint then
                config_thing.x_mult = config_thing.x_mult + config_thing.mod_x_mult
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex'), colour = G.C.FILTER})
                table.insert(effects, {})
            elseif context.playing_card_main then
                if config_thing.x_mult ~= 1 then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.total_end_of_round and (G.GAME.blind_on_deck == "Boss") and not context.blueprint then
                config_thing.x_mult = 1
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_reset'), colour = G.C.RED})
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mod_x_mult, config_thing.x_mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_brainstorm',
        card = {
            key = 'doj_brainstorm', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Brainstorm", 
            pos = {x=7,y=7},
            config = {}, 
            base = "S_T",
            is_joker = true,
            joker_rarity = 3,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
    }

    pc_add_cross_mod_card {
        key = 'doj_idol',
        card = {
            key = 'doj_idol', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "The Idol", 
            pos = {x=6,y=7},
            config = {x_mult = 2}, 
            base = "H_K",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.individual and (context.cardarea == G.play) and (card.area == G.play) and not context.end_of_round then
                local id = context.other_card:get_id()
                if id == G.GAME.current_round.idol_card.id and context.other_card:is_suit(G.GAME.current_round.idol_card.suit) then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = context.other_card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.x_mult, localize(G.GAME.current_round.idol_card.rank, 'ranks'), localize(G.GAME.current_round.idol_card.suit, 'suits_plural'), colours = {G.C.SUITS[G.GAME.current_round.idol_card.suit]}}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_dusk',
        card = {
            key = 'doj_dusk', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Dusk", 
            pos = {x=4,y=7},
            config = {}, 
            base = "S_4",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.repetition and (card.area == G.play) and (context.cardarea == G.play) then
                local special_table = {blueprint_card or card}
                if reps_i ~= 1 then
                    for j = 1, #reps[reps_i].cards do
                        table.insert(special_table, reps[reps_i].cards[j])
                    end
                end
                if G.GAME.current_round.hands_left == 0 then
                    table.insert(effects, {
                        message = localize('k_again_ex'),
                        repetitions = 1,
                        cards = special_table
                    })
                end
            elseif context.does_score then
                return true
            end
        end,
    }

    pc_add_cross_mod_card {
        key = 'doj_scary_face',
        card = {
            key = 'doj_scary_face', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Scary Face", 
            pos = {x=2,y=3},
            config = {chips = 30}, 
            base = "S_J",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.individual and (context.cardarea == G.play) and (card.area == G.play) and not context.end_of_round then
                if context.other_card:is_face() then
                    table.insert(effects, {
                        chips = config_thing.chips,
                        card = context.other_card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.chips}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_astronomer',
        card = {
            key = 'doj_astronomer', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Astronomer", 
            pos = {x=2,y=7},
            config = {}, 
            base = "D_9",
            is_joker = true,
            joker_rarity = 2,
            blueprint_incompat = true,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_swashbuckler',
        card = {
            key = 'doj_swashbuckler', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Swashbuckler", 
            pos = {x=9,y=5},
            config = {mult = 0}, 
            base = "C_3",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if config_thing.mult ~= 0 then
                    table.insert(effects, {
                        mult = config_thing.mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_midas_mask',
        card = {
            key = 'doj_midas_mask', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Midas Mask", 
            pos = {x=0,y=13},
            config = {mult = 0}, 
            base = "D_K",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.before and (context.cardarea == G.play) and not context.blueprint then
                local faces = 0
                for i = 1, #context.scoring_hand do
                    if (context.scoring_hand[i] ~= card) and context.scoring_hand[i]:is_face() then 
                        faces = faces + 1
                        context.scoring_hand[i]:set_ability(G.P_CENTERS.m_gold, nil, true)
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                context.scoring_hand[i]:juice_up()
                                return true
                            end
                        })) 
                    end
                end
                if faces > 0 then 
                    card_eval_status_text(blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_gold'), colour = G.C.MONEY})
                    table.insert(effects, {})
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_stone',
        card = {
            key = 'doj_stone', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Stone Joker", 
            pos = {x=9,y=0},
            config = {mod_chips = 25, stone_tally = 0}, 
            base = "S_T",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if config_thing.stone_tally ~= 0 then
                    table.insert(effects, {
                        chips = config_thing.stone_tally * config_thing.mod_chips,
                        card = blueprint_card or card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mod_chips, config_thing.stone_tally * config_thing.mod_chips}
        end,
        in_pool = function()
            for kk, vv in pairs(G.playing_cards) do
                if SMODS.has_enhancement(vv, 'm_stone') then
                    return true
                end
            end
            return false
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_throwback',
        card = {
            key = 'doj_throwback', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Throwback", 
            pos = {x=5,y=7},
            config = {x_mult = 1, mod_x_mult = 0.25}, 
            base = "H_5",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if config_thing.x_mult ~= 1 then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mod_x_mult, config_thing.x_mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_diet_cola',
        card = {
            key = 'doj_diet_cola', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Diet Cola", 
            pos = {x=8,y=14},
            config = {}, 
            base = "S_2",
            is_joker = true,
            joker_rarity = 2,
            sellable = true,
            blueprint_incompat = true,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {localize{type = 'name_text', set = 'Tag', key = 'tag_double', nodes = {}}}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_caino',
        card = {
            key = 'doj_caino', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Canio", 
            pos = {x=3,y=8},
            soul_pos = {x=3,y=9},
            config = {x_mult = 1, mod_x_mult = 1}, 
            base = "H_K",
            is_joker = true,
            joker_rarity = 4,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.remove_playing_cards and not context.blueprint then
                local gain = 0
                for i = 1, #context.removed do
                    if context.removed[i]:is_face() then
                        gain = gain + config_thing.mod_x_mult
                    end
                end
                config_thing.x_mult = config_thing.x_mult + gain
                if gain > 0 then
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_xmult', vars = {config_thing.x_mult}}, colour = G.C.FILTER})
                    table.insert(effects, {})
                end
            elseif context.playing_card_main then
                if config_thing.x_mult ~= 1 then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mod_x_mult, config_thing.x_mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_mystic_summit',
        card = {
            key = 'doj_mystic_summit', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Mystic Summit", 
            pos = {x=2,y=2},
            config = {mult = 15, d_remaining = 0}, 
            base = "C_5",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if G.GAME.current_round.discards_left == config_thing.d_remaining then
                    table.insert(effects, {
                        mult = config_thing.mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mult, config_thing.d_remaining}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_ice_cream',
        card = {
            key = 'doj_ice_cream', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Ice Cream", 
            pos = {x=4,y=10},
            config = {chips = 100, mod_chips = 5}, 
            base = "S_T",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                table.insert(effects, {
                    chips = config_thing.chips,
                    card = blueprint_card or card
                })
            elseif context.after and ((context.cardarea == G.play) or (context.cardarea == G.hand)) and not context.blueprint then
                config_thing.chips = config_thing.chips - config_thing.mod_chips
                if (context.cardarea == G.hand) and (config_thing.chips <= 0) then
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_melted_ex'), colour = G.C.CHIPS})
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                    func = function()
                            card.area:remove_card(card)
                            card:remove()
                            card = nil
                        return true; end}))
                elseif (config_thing.chips > 0) then
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_chips_minus',vars={config_thing.mod_chips}}, colour = G.C.CHIPS})
                    delay(0.1)
                    table.insert(effects, {})
                end
            elseif (context.destroying_card == card) and not context.blueprint and (context.cardarea == G.play) then
                if (config_thing.chips <= config_thing.mod_chips) and not context.blueprint then
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_melted_ex'), colour = G.C.CHIPS})
                    return true
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.chips, config_thing.mod_chips}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_turtle_bean',
        card = {
            key = 'doj_turtle_bean', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Turtle Bean", 
            pos = {x=4,y=13},
            config = {doj_hand_size = 5, mod_hand_size = 1, doj_debuffed = false}, 
            base = "S_5",
            is_joker = true,
            joker_rarity = 2,
            blueprint_incompat = true,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.total_end_of_round then
                config_thing.doj_hand_size = config_thing.doj_hand_size - config_thing.mod_hand_size
                if card.area == G.hand then
                    G.hand.config.real_card_limit = (G.hand.config.real_card_limit or G.hand.config.card_limit) - config_thing.mod_hand_size
                    G.hand.config.card_limit = math.max(0, G.hand.config.real_card_limit)
                end
                if config_thing.doj_hand_size > 0 then
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_handsize_minus',vars={config_thing.mod_hand_size}}, colour = G.C.FILTER})
                    table.insert(effects, {})
                else
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_eaten_ex'), colour = G.C.FILTER})
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                    func = function()
                            card.area:remove_card(card)
                            card:remove()
                            card = nil
                        return true; end}))
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.doj_hand_size, config_thing.mod_hand_size}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_cavendish',
        card = {
            key = 'doj_cavendish', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Cavendish", 
            pos = {x=5,y=11},
            config = {x_mult = 3, odds = 1000}, 
            base = "H_3",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                table.insert(effects, {
                    x_mult = config_thing.x_mult,
                    card = blueprint_card or card
                })
            elseif context.total_end_of_round and not context.blueprint then
                if pseudorandom('cavendish') < G.GAME.probabilities.normal/config_thing.odds then
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_extinct_ex'), colour = G.C.FILTER})
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                    func = function()
                            card.area:remove_card(card)
                            card:remove()
                            card = nil
                        return true; end}))
                else
                    table.insert(effects, {})
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.x_mult, G.GAME.probabilities.normal, config_thing.odds}
        end,
        in_pool = function()
            return G.GAME.pool_flags.gros_michel_extinct
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_juggler',
        card = {
            key = 'doj_juggler', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Juggler", 
            pos = {x=0,y=1},
            config = {doj_hand_size = 1, doj_debuffed = false}, 
            base = "S_A",
            is_joker = true,
            joker_rarity = 1,
            blueprint_incompat = true,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.doj_hand_size}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_seance',
        card = {
            key = 'doj_seance', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Seance", 
            pos = {x=0,y=12},
            config = {}, 
            base = "S_A",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.before and ((context.cardarea == G.play) or (context.cardarea == G.hand)) then
                if next(context.poker_hands["Straight Flush"]) then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    G.E_MANAGER:add_event(Event({
                        trigger = 'before',
                        delay = 0.0,
                        func = (function()
                                local card_ = create_card('Spectral',G.consumeables, nil, nil, nil, nil, nil, 'sea')
                                card_:add_to_deck()
                                G.consumeables:emplace(card_)
                                G.GAME.consumeable_buffer = 0
                            return true
                        end)}))
                    card_eval_status_text(blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_plus_spectral'), colour = G.C.SECONDARY_SET.Spectral})
                    table.insert(effects, {})
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {localize("Straight Flush", 'poker_hands')}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_riff_raff',
        card = {
            key = 'doj_riff_raff', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Riff-Raff", 
            pos = {x=1,y=12},
            config = {jokers = 2}, 
            base = "S_6",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.setting_blind then
                local jokers_to_create = math.min(config_thing.jokers, G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer))
                if jokers_to_create > 0 then
                    G.GAME.joker_buffer = G.GAME.joker_buffer + jokers_to_create
                    G.E_MANAGER:add_event(Event({
                        func = function() 
                            for i = 1, jokers_to_create do
                                local card = create_card('Joker', G.jokers, nil, 0, nil, nil, nil, 'rif')
                                card:add_to_deck()
                                G.jokers:emplace(card)
                                card:start_materialize()
                                G.GAME.joker_buffer = 0
                            end
                            return true
                    end}))   
                    card_eval_status_text(blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_plus_joker'), colour = G.C.BLUE}) 
                    table.insert(effects, {})
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.jokers}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_supernova',
        card = {
            key = 'doj_supernova', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Supernova", 
            pos = {x=2,y=4},
            config = {}, 
            base = "C_9",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                table.insert(effects, {
                    mult = G.GAME.hands[context.scoring_name].played,
                    card = blueprint_card or card
                })
            elseif context.does_score then
                return true
            end
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_smeared',
        card = {
            key = 'doj_smeared', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Smeared Joker", 
            pos = {x=4,y=6},
            config = {}, 
            base = "S_8",
            is_joker = true,
            joker_rarity = 2,
            blueprint_incompat = true,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
    }

    pc_add_cross_mod_card {
        key = 'doj_ceremonial',
        card = {
            key = 'doj_ceremonial', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Ceremonial Dagger", 
            pos = {x=5,y=5},
            config = {mult = 0}, 
            base = "C_8",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if config_thing.mult > 0 then
                    table.insert(effects, {
                        mult = config_thing.mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.end_of_round and (context.cardarea == G.hand) and not context.individual and not context.repetition and not context.blueprint then
                local sliced_card = nil
                local index = -1
                for i = 1, #G.hand.cards do
                    if G.hand.cards[i] == card then
                        index = i
                        break
                    end
                end
                if (index ~= -1) and (index ~= #G.hand.cards) then
                    sliced_card = G.hand.cards[index + 1]
                    G.E_MANAGER:add_event(Event({trigger = 'immediate',func = function()
                        sliced_card:start_dissolve({HEX("57ecab")}, nil, 1.6)
                        return true
                    end}))
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_mult', vars = {config_thing.mult+2*sliced_card.sell_cost}}, colour = G.C.RED, no_juice = true})
                    table.insert(effects, {})
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_madness',
        card = {
            key = 'doj_madness', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Madness", 
            pos = {x=8,y=11},
            config = {x_mult = 1, mod_x_mult = 0.5}, 
            base = "H_K",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if config_thing.x_mult ~= 1 then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.setting_blind and not context.blueprint and not context.blind.boss then
                config_thing.x_mult = config_thing.x_mult + config_thing.mod_x_mult
                local destructable_jokers = {}
                for i = 1, #G.jokers.cards do
                    if not G.jokers.cards[i].ability.eternal and not G.jokers.cards[i].getting_sliced then destructable_jokers[#destructable_jokers+1] = G.jokers.cards[i] end
                end
                local joker_to_destroy = (#destructable_jokers > 0) and pseudorandom_element(destructable_jokers, pseudoseed('madness')) or nil

                if joker_to_destroy then 
                    joker_to_destroy.getting_sliced = true
                    G.E_MANAGER:add_event(Event({func = function()
                        joker_to_destroy:start_dissolve({G.C.RED}, nil, 1.6)
                    return true end }))
                end
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_xmult', vars = {config_thing.x_mult}}})
                table.insert(effects, {})
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mod_x_mult, config_thing.x_mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_8_ball',
        card = {
            key = 'doj_8_ball', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "8 Ball", 
            pos = {x=0,y=5},
            config = {odds = 4}, 
            base = "S_8",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.individual and not context.blueprint then
                if context.individual and (context.cardarea == G.play) and (card.area == G.play) then
                    if (context.other_card:get_id() == 8) and (#G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit) and ((pseudorandom('8ball') < G.GAME.probabilities.normal/config_thing.odds)) then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        table.insert(effects, {
                            extra = {focus = blueprint_card or card, message = localize('k_plus_tarot'), colour = G.C.SECONDARY_SET.Tarot, func = function()
                                G.E_MANAGER:add_event(Event({
                                    trigger = 'immediate',
                                    func = (function()
                                            local card = create_card('Tarot',G.consumeables, nil, nil, nil, nil, nil, '8ba')
                                            card:add_to_deck()
                                            G.consumeables:emplace(card)
                                            G.GAME.consumeable_buffer = 0
                                        return true
                                end)}))
                            end},
                            card = blueprint_card or card
                        })
                    elseif (context.other_card:get_id() == 8) and (#G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit) then
                        table.insert(effects, {})
                    end
                end
            elseif context.get_id then
                return 8
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {G.GAME.probabilities.normal, config_thing.odds}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_egg',
        card = {
            key = 'doj_egg', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Egg", 
            pos = {x=0,y=10},
            config = {mod_sell_value = 3}, 
            base = "D_3",
            is_joker = true,
            joker_rarity = 1,
            sellable = true,
            blueprint_incompat = true,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.end_of_round and (context.cardarea == G.hand) and not context.individual and not context.repetition and not context.blueprint then
                card.ability.extra_value = (card.ability.extra_value or 0) + config_thing.mod_sell_value
                card:set_cost()
                table.insert(effects, {
                    message = localize("k_val_up"),
                    colour = G.C.MONEY,
                    card = card
                })
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mod_sell_value}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_popcorn',
        card = {
            key = 'doj_popcorn', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Popcorn", 
            pos = {x=1,y=15},
            config = {mult = 20, mod_mult = 4}, 
            base = "C_4",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if config_thing.mult > 0 then
                    table.insert(effects, {
                        mult = config_thing.mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.total_end_of_round and not context.blueprint then
                config_thing.mult = config_thing.mult - config_thing.mod_mult
                if config_thing.mult > 0 then
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_mult_minus',vars={config_thing.mod_mult}}, colour = G.C.MULT})
                    table.insert(effects, {})
                else
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_eaten_ex'), colour = G.C.RED})
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                    func = function()
                            card.area:remove_card(card)
                            card:remove()
                            card = nil
                        return true; end}))
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mult, config_thing.mod_mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_mr_bones',
        card = {
            key = 'doj_mr_bones', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Mr. Bones", 
            pos = {x=3,y=4},
            config = {}, 
            base = "S_5",
            is_joker = true,
            joker_rarity = 2,
            blueprint_incompat = true,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.end_of_round and (context.cardarea == G.hand) and not context.individual and not context.repetition and not context.blueprint and context.game_over then
                if to_big_talisman(G.GAME.chips)/G.GAME.blind.chips >= to_big_talisman(0.25) then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.hand_text_area.blind_chips:juice_up()
                            G.hand_text_area.game_chips:juice_up()
                            play_sound('tarot1')
                            card:start_dissolve()
                            return true
                        end
                    }))
                    table.insert(effects, {
                        message = localize('k_saved_ex'),
                        saved = true,
                        colour = G.C.RED
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_shoot_the_moon',
        card = {
            key = 'doj_shoot_the_moon', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Shoot the Moon", 
            pos = {x=2,y=6},
            config = {mult = 13}, 
            base = "C_3",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.individual and (context.cardarea == G.hand) and (card.area == G.play) and not context.end_of_round and G.hand.cards[1] then
                if context.other_card:get_id() == 12 then 
                    if context.other_card.debuff then
                        table.insert(effects, {
                            message = localize('k_debuffed'),
                            colour = G.C.RED,
                            card = blueprint_card or self,
                        })
                    else
                        table.insert(effects, {
                            mult = config_thing.mult,
                            card = blueprint_card or self,
                        })
                    end
                end
            elseif context.get_id then
                return 12
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_duo',
        card = {
            key = 'doj_duo', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "The Duo", 
            pos = {x=5,y=4},
            config = {x_mult = 2}, 
            base = "H_2",
            is_joker = true,
            joker_rarity = 3,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if next(context.poker_hands["Pair"]) then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.x_mult, localize('Pair', 'poker_hands')}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_obelisk',
        card = {
            key = 'doj_obelisk', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Obelisk", 
            pos = {x=9,y=12},
            config = {x_mult = 1, mod_x_mult = 0.2}, 
            base = "H_6",
            is_joker = true,
            joker_rarity = 3,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config
            if context.before and (context.cardarea == G.play) then
                local reset = true
                local play_more_than = (G.GAME.hands[context.scoring_name].played or 0)
                for k, v in pairs(G.GAME.hands) do
                    if k ~= context.scoring_name and v.played >= play_more_than and v.visible then
                        reset = false
                    end
                end
                if reset then
                    if config_thing.x_mult > 1 then
                        config_thing.x_mult = 1
                        card_eval_status_text(blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_reset'), colour = G.C.FILTER})
                        table.insert(effects, {})
                    end
                else
                    config_thing.x_mult = config_thing.x_mult + config_thing.mod_x_mult
                    table.insert(effects, {})
                end
            elseif context.playing_card_main then
                table.insert(effects, {
                    x_mult = config_thing.x_mult,
                    card = blueprint_card or card
                })
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mod_x_mult, config_thing.x_mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_sly',
        card = {
            key = 'doj_sly', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Sly Joker", 
            pos = {x=0,y=14},
            config = {chips = 50}, 
            base = "S_2",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if next(context.poker_hands["Pair"]) then
                    table.insert(effects, {
                        chips = config_thing.chips,
                        card = blueprint_card or card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.chips, localize('Pair', 'poker_hands')}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_crafty',
        card = {
            key = 'doj_crafty', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Crafty Joker", 
            pos = {x=4,y=14},
            config = {chips = 80}, 
            base = "S_5",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main or context.playing_card_hand then
                if next(context.poker_hands["Flush"]) then
                    table.insert(effects, {
                        chips = config_thing.chips,
                        card = blueprint_card or card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.chips, localize('Flush', 'poker_hands')}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_to_the_moon',
        card = {
            key = 'doj_to_the_moon', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "To the Moon", 
            pos = {x=8,y=13},
            config = {interest = 1}, 
            base = "D_5",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.interest}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_merry_andy',
        card = {
            key = 'doj_merry_andy', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Merry Andy", 
            pos = {x=8,y=0},
            config = {doj_discards = 3, doj_hand_size = -1, doj_debuffed = false}, 
            base = "S_3",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config
            if context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.doj_discards, config_thing.doj_hand_size}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_burglar',
        card = {
            key = 'doj_burglar', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Burglar", 
            pos = {x=1,y=10},
            config = {hands = 3}, 
            base = "S_J",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config
            if context.setting_blind then
                G.E_MANAGER:add_event(Event({func = function()
                    ease_discard(-G.GAME.current_round.discards_left, nil, true)
                    ease_hands_played(config_thing.hands)
                    card_eval_status_text(blueprint_card or card, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_hands', vars = {config_thing.hands}}})
                return true end }))
                table.insert(effects, {})
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.hands}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_hit_the_road',
        card = {
            key = 'doj_hit_the_road', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Hit the Road", 
            pos = {x=8,y=5},
            config = {x_mult = 1, mod_x_mult = 0.5}, 
            base = "H_J",
            is_joker = true,
            joker_rarity = 3,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if config_thing.x_mult ~= 1 then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.discard and (context.other_card:get_id() == 11) then
                config_thing.x_mult = config_thing.x_mult + config_thing.mod_x_mult
                card_eval_status_text(blueprint_card or card, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_xmult',vars={config_thing.x_mult}}, colour = G.C.RED})
                table.insert(effects, {})
            elseif context.get_id then
                return 11
            elseif context.total_end_of_round and not context.blueprint then
                config_thing.x_mult = 1
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_reset'), colour = G.C.RED})
                table.insert(effects, {})
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mod_x_mult, config_thing.x_mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_seeing_double',
        card = {
            key = 'doj_seeing_double', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Seeing Double", 
            pos = {x=4,y=4},
            config = {x_mult = 2}, 
            base = "C_2",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if SMODS.seeing_double_check(context.scoring_hand, 'Clubs') then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.is_suit then
                if ((context.is_suit == "Spades") and next(find_joker('Smeared Joker'))) or (context.is_suit == "Clubs") then
                    return true
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.x_mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_drivers_license',
        card = {
            key = 'doj_drivers_license', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Driver's License", 
            pos = {x=0,y=7},
            config = {x_mult = 3, tally = 0}, 
            base = "H_6",
            is_joker = true,
            joker_rarity = 3,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if config_thing.tally >= 16 then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.x_mult, config_thing.tally}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_green_joker',
        card = {
            key = 'doj_green_joker', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Green Joker", 
            pos = {x=2,y=11},
            config = {mult = 0, hand_add = 1, discard_sub = 1}, 
            base = "C_7",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if config_thing.mult > 0 then
                    table.insert(effects, {
                        mult = config_thing.mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.before and ((context.cardarea == G.play) or (context.cardarea == G.hand)) and not context.blueprint then
                config_thing.mult = config_thing.mult + config_thing.hand_add
                card_eval_status_text(blueprint_card or card, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_mult',vars={config_thing.hand_add}}})
                table.insert(effects, {})
            elseif context.pre_discard and (config_thing.mult > 0) then
                config_thing.mult = config_thing.mult - config_thing.discard_sub
                card_eval_status_text(blueprint_card or card, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_mult_minus',vars={config_thing.discard_sub}}})
                table.insert(effects, {})
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.hand_add, config_thing.discard_sub, config_thing.mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_pareidolia',
        card = {
            key = 'doj_pareidolia', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Pareidolia", 
            pos = {x=6,y=3},
            config = {}, 
            base = "S_Q",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if (context.before or context.after) and (context.cardarea == G.play) then
                for i = 1, #G.playing_cards do
                    G.playing_cards[i]:set_debuff()
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
    }

    pc_add_cross_mod_card {
        key = 'doj_certificate',
        card = {
            key = 'doj_certificate', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Certificate", 
            pos = {x=8,y=8},
            config = {}, 
            base = "S_4",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.drawn then
                card.ability.already_drawn = G.GAME.round
                local _card = create_playing_card({
                    front = pseudorandom_element(G.P_CARDS, pseudoseed('cert_fr')),
                    center = G.P_CENTERS.c_base}, G.discard, true, nil, {G.C.SECONDARY_SET.Enhanced}, true)
                _card:set_seal(SMODS.poll_seal({guaranteed = true, type_key = 'certsl'}))
                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.hand:emplace(_card)
                        _card:start_materialize()
                        G.GAME.blind:debuff_card(_card)
                        G.hand:sort()
                        return true
                    end}))
                playing_card_joker_effects({_card})
                table.insert(effects, {})
            elseif context.does_score then
                return true
            end
        end,
    }

    pc_add_cross_mod_card {
        key = 'doj_gros_michel',
        card = {
            key = 'doj_gros_michel', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Gros Michel", 
            pos = {x=7,y=6},
            config = {mult = 15, odds = 6}, 
            base = "C_6",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                table.insert(effects, {
                    mult = config_thing.mult,
                    card = blueprint_card or card
                })
            elseif context.total_end_of_round and not context.blueprint then
                if pseudorandom('gros_michel') < G.GAME.probabilities.normal/config_thing.odds then
                    G.GAME.pool_flags.gros_michel_extinct = true
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_extinct_ex'), colour = G.C.FILTER})
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                    func = function()
                            card.area:remove_card(card)
                            card:remove()
                            card = nil
                        return true; end}))
                else
                    table.insert(effects, {})
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mult, G.GAME.probabilities.normal, config_thing.odds}
        end,
        in_pool = function()
            return not G.GAME.pool_flags.gros_michel_extinct
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_marble',
        card = {
            key = 'doj_marble', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Marble Joker", 
            pos = {x=3,y=2},
            config = {}, 
            base = "S_5",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.setting_blind and not context.blueprint then
                local front = pseudorandom_element(G.P_CARDS, pseudoseed('marb_fr'))
                G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                local card_ = Card(G.discard.T.x + G.discard.T.w/2, G.discard.T.y, G.CARD_W, G.CARD_H, front, G.P_CENTERS.m_stone, {playing_card = G.playing_card})
                G.E_MANAGER:add_event(Event({
                    func = function()
                        card_:start_materialize({G.C.SECONDARY_SET.Enhanced})
                        G.play:emplace(card_)
                        table.insert(G.playing_cards, card_)
                        return true
                    end}))
                card_eval_status_text(blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_plus_stone'), colour = G.C.SECONDARY_SET.Enhanced})
                
                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.deck.config.card_limit = G.deck.config.card_limit + 1
                        return true
                    end}))
                    draw_card(G.play,G.deck, 90,'up', nil)
                
                playing_card_joker_effects({card_})
                table.insert(effects, {})
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_baron',
        card = {
            key = 'doj_baron', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Baron", 
            pos = {x=6,y=12},
            config = {x_mult = 1.5}, 
            base = "H_K",
            is_joker = true,
            joker_rarity = 3,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.individual and (context.cardarea == G.hand) and (card.area == G.play) and not context.end_of_round and G.hand.cards[1] then
                if context.other_card:get_id() == 13 then 
                    if context.other_card.debuff then
                        table.insert(effects, {
                            message = localize('k_debuffed'),
                            colour = G.C.RED,
                            card = blueprint_card or self,
                        })
                    else
                        table.insert(effects, {
                            x_mult = config_thing.x_mult,
                            card = blueprint_card or self,
                        })
                    end
                end
            elseif context.get_id then
                return 13
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.x_mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_cartomancer',
        card = {
            key = 'doj_cartomancer', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Cartomancer", 
            pos = {x=7,y=3},
            config = {}, 
            base = "S_Q",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.setting_blind and (#G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit) then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    func = (function()
                        G.E_MANAGER:add_event(Event({
                            func = function() 
                                local card = create_card('Tarot',G.consumeables, nil, nil, nil, nil, nil, 'car')
                                card:add_to_deck()
                                G.consumeables:emplace(card)
                                G.GAME.consumeable_buffer = 0
                                return true
                            end}))   
                            card_eval_status_text(blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_plus_tarot'), colour = G.C.PURPLE})                       
                        return true
                    end)}))
                    table.insert(effects, {})
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_wily',
        card = {
            key = 'doj_wily', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Wily Joker", 
            pos = {x=1,y=14},
            config = {chips = 100}, 
            base = "C_3",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if next(context.poker_hands["Three of a Kind"]) then
                    table.insert(effects, {
                        chips = config_thing.chips,
                        card = blueprint_card or card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.chips, localize('Three of a Kind', 'poker_hands')}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_oops',
        card = {
            key = 'doj_oops', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Oops! All 6s", 
            pos = {x=5,y=6},
            config = {}, 
            base = "S_6",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.does_score then
                return true
            end
        end,
    }

    pc_add_cross_mod_card {
        key = 'doj_vampire',
        card = {
            key = 'doj_vampire', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Vampire", 
            pos = {x=2,y=12},
            config = {x_mult = 1, mod_x_mult = 0.1}, 
            base = "H_K",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.before and (context.cardarea == G.play) and not context.blueprint then
                local enhanced = {}
                for k, v in ipairs(context.scoring_hand) do
                    if (v ~= card) and v.config.center ~= G.P_CENTERS.c_base and not v.debuff and not v.vampired then 
                        enhanced[#enhanced+1] = v
                        v.vampired = true
                        v:set_ability(G.P_CENTERS.c_base, nil, true)
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                v:juice_up()
                                v.vampired = nil
                                return true
                            end
                        })) 
                    end
                end

                if #enhanced > 0 then 
                    config_thing.x_mult = config_thing.x_mult + config_thing.mod_x_mult*#enhanced
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_xmult', vars = {config_thing.x_mult}}, colour = G.C.MULT})
                    table.insert(effects, {})
                end
            elseif context.playing_card_main then
                if config_thing.x_mult ~= 1 then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mod_x_mult, config_thing.x_mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_shortcut',
        card = {
            key = 'doj_shortcut', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Shortcut", 
            pos = {x=3,y=12},
            config = {}, 
            base = "S_3",
            is_joker = true,
            joker_rarity = 2,
            blueprint_incompat = true,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.does_score then
                return true
            end
        end,
    }

    pc_add_cross_mod_card {
        key = 'doj_walkie_talkie',
        card = {
            key = 'doj_walkie_talkie', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Walkie Talkie", 
            pos = {x=8,y=15},
            config = {chips = 10, mult = 4}, 
            base = "C_T",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config
            if context.individual and (context.cardarea == G.play) and (card.area == G.play) and not context.end_of_round then
                local id = context.other_card:get_id()
                if (id == 4) or (id == 10) then
                    table.insert(effects, {
                        mult = config_thing.mult,
                        chips = config_thing.chips,
                        card = context.other_card
                    })
                end
            elseif context.get_id then
                return 10
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.chips, config_thing.mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_baseball',
        card = {
            key = 'doj_baseball', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Baseball Card", 
            pos = {x=6,y=14},
            config = {x_mult = 1.5}, 
            base = "C_5",
            is_joker = true,
            joker_rarity = 3,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config
            if context.playing_card_main then
                for i = 1, #G.jokers.cards do
                    if (G.jokers.cards[i].config.center.rarity == 2) or (G.jokers.cards[i].config.center.rarity == "Uncommon") then
                        table.insert(effects, {
                            extra = {func = function()
                                G.E_MANAGER:add_event(Event({
                                    trigger = 'immediate',
                                    func = (function()
                                        G.jokers.cards[i]:juice_up()
                                        return true
                                end)}))
                            end},
                            x_mult = config_thing.x_mult,
                            card = blueprint_card or card
                        })
                        
                    end
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.x_mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_gift_card',
        card = {
            key = 'doj_gift_card', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Gift Card", 
            pos = {x=3,y=13},
            config = {sell_value = 1}, 
            base = "D_4",
            is_joker = true,
            joker_rarity = 2,
            blueprint_incompat = true,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config
            if context.end_of_round and (context.cardarea == G.hand) and not context.individual and not context.repetition and not context.blueprint then
                for k, v in ipairs(G.jokers.cards) do
                    if v.set_cost then 
                        v.ability.extra_value = (v.ability.extra_value or 0) + config_thing.sell_value
                        v:set_cost()
                    end
                end
                for k, v in ipairs(G.consumeables.cards) do
                    if v.set_cost then 
                        v.ability.extra_value = (v.ability.extra_value or 0) + config_thing.sell_value
                        v:set_cost()
                    end
                end
                table.insert(effects, {
                    message = localize("k_val_up"),
                    colour = G.C.MONEY,
                    card = card
                })
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.sell_value}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_business',
        card = {
            key = 'doj_business', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Business Card", 
            pos = {x=1,y=4},
            config = {odds = 2}, 
            base = "D_2",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config
            if context.individual and (context.cardarea == G.play) and (card.area == G.play) and not context.end_of_round then
                if context.other_card:is_face() and (pseudorandom('business') < G.GAME.probabilities.normal/config_thing.odds) then
                    table.insert(effects, {
                        dollars = 2,
                        card = context.other_card
                    })
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {G.GAME.probabilities.normal, config_thing.odds}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_hologram',
        card = {
            key = 'doj_hologram', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Hologram", 
            pos = {x=4,y=12}, 
            soul_pos = {x=2,y=9},
            config = {x_mult = 1, mod_x_mult = 0.25}, 
            base = "H_5",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config
            if context.playing_card_main then
                if config_thing.x_mult ~= 1 then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.playing_card_added and ((context.cardarea == G.play) or (context.cardarea == G.hand)) and (not context.blueprint) and context.cards and context.cards[1] then
                config_thing.x_mult = config_thing.x_mult + #context.cards*config_thing.mod_x_mult
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_xmult', vars = {config_thing.x_mult}}})
                table.insert(effects, {})
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mod_x_mult, config_thing.x_mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_splash',
        card = {
            key = 'doj_splash', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Splash", 
            pos = {x=6,y=10}, 
            config = {}, 
            base = "S_5",
            is_joker = true,
            joker_rarity = 1,
            blueprint_incompat = true,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config
            if context.does_score then
                return true
            end
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_hiker',
        card = {
            key = 'doj_hiker', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Hiker", 
            pos = {x=0,y=11}, 
            config = {chips = 5}, 
            base = "S_5",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config
            if context.individual and (context.cardarea == G.play) and (card.area == G.play) and not context.end_of_round then
                context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus or 0
                context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus + config_thing.chips
                table.insert(effects, {
                    extra = {message = localize('k_upgrade_ex'), colour = G.C.CHIPS},
                    colour = G.C.CHIPS,
                    card = card
                })
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.chips}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_hack',
        card = {
            key = 'doj_hack', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Hack", 
            pos = {x=5,y=2},
            config = {}, 
            base = "S_5",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.repetition and (card.area == G.play) and (context.cardarea == G.play) then
                local special_table = {blueprint_card or card}
                if reps_i ~= 1 then
                    for j = 1, #reps[reps_i].cards do
                        table.insert(special_table, reps[reps_i].cards[j])
                    end
                end
                local id = context.other_card:get_id()
                if (id == 2) or (id == 3) or (id == 4) or (id == 5) then
                    table.insert(effects, {
                        message = localize('k_again_ex'),
                        repetitions = 1,
                        cards = special_table
                    })
                end
            elseif context.get_id then
                return 5
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
    }

    pc_add_cross_mod_card {
        key = 'doj_ancient',
        card = {
            key = 'doj_ancient', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Ancient Joker", 
            pos = {x=7,y=15},
            config = {x_mult = 1.5}, 
            base = "H_4",
            is_joker = true,
            joker_rarity = 3,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.individual and (context.cardarea == G.play) and (card.area == G.play) and not context.end_of_round then
                local id = context.other_card:get_id()
                if context.other_card:is_suit(G.GAME.current_round.ancient_card.suit) then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = context.other_card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.x_mult, localize(G.GAME.current_round.ancient_card.suit, 'suits_singular'), colours = {G.C.SUITS[G.GAME.current_round.ancient_card.suit]}}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_blackboard',
        card = {
            key = 'doj_blackboard', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Blackboard", 
            pos = {x=2,y=10},
            config = {x_mult = 3}, 
            base = "C_3",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                local black_suits, all_cards = 0, 0
                for k, v in ipairs(G.hand.cards) do
                    all_cards = all_cards + 1
                    if v:is_suit('Clubs', nil, true) or v:is_suit('Spades', nil, true) then
                        black_suits = black_suits + 1
                    end
                end
                if black_suits == all_cards then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.x_mult, localize("Spades", 'suits_plural'), localize("Clubs", 'suits_plural')}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_castle',
        card = {
            key = 'doj_castle', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Castle", 
            pos = {x=9,y=15},
            config = {chips = 0, mod_chips = 3}, 
            base = "S_5",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if config_thing.chips then
                    table.insert(effects, {
                        chips = config_thing.chips,
                        card = blueprint_card or card
                    })
                end
            elseif context.discard and context.other_card:is_suit(G.GAME.current_round.castle_card.suit) and not context.other_card.debuff then
                config_thing.chips = config_thing.chips + config_thing.mod_chips
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex'), colour = G.C.CHIPS})
                table.insert(effects, {})
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mod_chips, localize(G.GAME.current_round.castle_card.suit, 'suits_singular'), config_thing.chips, colours = {G.C.SUITS[G.GAME.current_round.castle_card.suit]}}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_mad',
        card = {
            key = 'doj_mad', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Mad Joker", 
            pos = {x=4,y=0},
            config = {mult = 10}, 
            base = "C_8",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if next(context.poker_hands["Two Pair"]) then
                    table.insert(effects, {
                        mult = config_thing.mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mult, localize('Two Pair', 'poker_hands')}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_trading_card',
        card = {
            key = 'doj_trading_card', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Trading Card", 
            pos = {x=9,y=14},
            config = {dollars = 3}, 
            base = "S_3",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.discard and (#context.full_hand == 1) and (G.GAME.current_round.discards_used <= 0) and not context.blueprint then
                ease_dollars(config_thing.dollars)
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('$')..config_thing.dollars, delay = 0.45, colour = G.C.MONEY})
                return {
                    remove = true,
                }
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.dollars}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_crazy',
        card = {
            key = 'doj_crazy', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Crazy Joker", 
            pos = {x=5,y=0},
            config = {mult = 12}, 
            base = "C_9",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main or context.playing_card_hand then
                if next(context.poker_hands["Straight"]) then
                    table.insert(effects, {
                        mult = config_thing.mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mult,  localize('Straight', 'poker_hands')}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_zany',
        card = {
            key = 'doj_zany', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Zany Joker", 
            pos = {x=3,y=0},
            config = {mult = 12}, 
            base = "C_3",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if next(context.poker_hands["Three of a Kind"]) then
                    table.insert(effects, {
                        mult = config_thing.mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mult,  localize('Three of a Kind', 'poker_hands')}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_devious',
        card = {
            key = 'doj_devious', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Devious Joker", 
            pos = {x=3,y=14},
            config = {chips = 100}, 
            base = "S_9",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main or context.playing_card_hand then
                if next(context.poker_hands["Straight"]) then
                    table.insert(effects, {
                        chips = config_thing.chips,
                        card = blueprint_card or card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.chips,  localize('Straight', 'poker_hands')}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_loyalty_card',
        card = {
            key = 'doj_loyalty_card', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Loyalty Card", 
            pos = {x=4,y=2},
            config = {x_mult = 4, hands = 6, hands_todo = 5}, 
            base = "H_4",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if config_thing.hands_todo == 0 then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.after and ((context.cardarea == G.play) or (context.cardarea == G.hand)) and not context.blueprint then
                if config_thing.hands_todo == 0 then
                    config_thing.hands_todo = config_thing.hands
                end
                config_thing.hands_todo = config_thing.hands_todo - 1
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.x_mult, config_thing.hands, localize{type = 'variable', key = (config_thing.hands_todo == 0 and 'loyalty_active' or 'loyalty_inactive'), vars = {config_thing.hands_todo}}}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_clever',
        card = {
            key = 'doj_clever', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Clever Joker", 
            pos = {x=2,y=14},
            config = {chips = 80}, 
            base = "S_8",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if next(context.poker_hands["Two Pair"]) then
                    table.insert(effects, {
                        chips = config_thing.chips,
                        card = blueprint_card or card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.chips, localize('Two Pair', 'poker_hands')}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_even_steven',
        card = {
            key = 'doj_even_steven', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Even Steven", 
            pos = {x=8,y=3},
            config = {mult = 4}, 
            base = "C_T",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.individual and (context.cardarea == G.play) and (card.area == G.play) and not context.end_of_round then
                local id = context.other_card:get_id()
                if (id == 2) or (id == 4) or (id == 6) or (id == 8) or (id == 10) then
                    table.insert(effects, {
                        mult = config_thing.mult,
                        card = context.other_card
                    })
                end
            elseif context.get_id then
                return 10
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_odd_todd',
        card = {
            key = 'doj_odd_todd', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Odd Todd", 
            pos = {x=9,y=3},
            config = {chips = 31}, 
            base = "S_A",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.individual and (context.cardarea == G.play) and (card.area == G.play) and not context.end_of_round then
                local id = context.other_card:get_id()
                if (id == 3) or (id == 5) or (id == 7) or (id == 9) or (id == 14) then
                    table.insert(effects, {
                        chips = config_thing.chips,
                        card = context.other_card
                    })
                end
            elseif context.get_id then
                return 14
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.chips}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_todo_list',
        card = {
            key = 'doj_todo_list', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "To Do List", 
            pos = {x=4,y=11},
            config = {dollars = 4, poker_hand = "High Card"}, 
            base = "D_4",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.before and (context.cardarea == G.play) then
                ease_dollars(config_thing.dollars)
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('$')..config_thing.dollars, colour = G.C.MONEY})
                table.insert(effects, {})
            elseif context.total_end_of_round then
                local _poker_hands = {}
                for k, v in pairs(G.GAME.hands) do
                    if v.visible and k ~= config_thing.poker_hand then _poker_hands[#_poker_hands+1] = k end
                end
                config_thing.poker_hand = pseudorandom_element(_poker_hands, pseudoseed('to_do'))
                card_eval_status_text(blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_reset')})
                table.insert(effects, {})
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.dollars, localize(config_thing.poker_hand, 'poker_hands')}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_erosion',
        card = {
            key = 'doj_erosion', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Erosion", 
            pos = {x=5,y=13},
            config = {mult = 4}, 
            base = "C_4",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                local total_mult = math.max(0,config_thing.mult*(G.playing_cards and (G.GAME.starting_deck_size - #G.playing_cards) or 0))
                if total_mult > 0 then
                    table.insert(effects, {
                        mult = total_mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mult, math.max(0,config_thing.mult*(G.playing_cards and (G.GAME.starting_deck_size - #G.playing_cards) or 0)), G.GAME.starting_deck_size}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_hallucination',
        card = {
            key = 'doj_hallucination', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Hallucination", 
            pos = {x=9,y=13}, 
            config = {odds = 2}, 
            base = "S_2",
            is_joker = true,
            joker_rarity = 1,
            blueprint_incompat = true,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config
            if context.open_booster then
                if (#G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit) and (pseudorandom('halu'..G.GAME.round_resets.ante) < G.GAME.probabilities.normal/config_thing.odds) then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    G.E_MANAGER:add_event(Event({
                        trigger = 'before',
                        delay = 0.0,
                        func = (function()
                                local card = create_card('Tarot',G.consumeables, nil, nil, nil, nil, nil, 'hal')
                                card:add_to_deck()
                                G.consumeables:emplace(card)
                                G.GAME.consumeable_buffer = 0
                            return true
                        end)}))
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_plus_tarot'), colour = G.C.PURPLE})
                else
                    table.insert(effects, {})
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {G.GAME.probabilities.normal, config_thing.odds}
        end
        
    }

    pc_add_cross_mod_card {
        key = 'doj_glass',
        card = {
            key = 'doj_glass', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Glass Joker", 
            pos = {x=1,y=3},
            config = {x_mult = 1, mod_x_mult = 0.75}, 
            base = "H_7",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.remove_playing_cards and not context.blueprint then
                local gain = 0
                for i = 1, #context.removed do
                    if SMODS.has_enhancement(context.removed[i], 'm_glass') then
                        gain = gain + config_thing.mod_x_mult
                    end
                end
                config_thing.x_mult = config_thing.x_mult + gain
                if gain > 0 then
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_xmult', vars = {config_thing.x_mult}}, colour = G.C.FILTER})
                    table.insert(effects, {})
                end
            elseif context.using_consumeable and (context.using_consumeable.ability.name == "The Hanged Man") and not context.blueprint then
                local gain = 0
                for i = 1, #G.hand.highlighted do
                    if SMODS.has_enhancement(G.hand.highlighted[i], 'm_glass') then
                        gain = gain + config_thing.mod_x_mult
                    end
                end
                config_thing.x_mult = config_thing.x_mult + gain
                if gain > 0 then
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_xmult', vars = {config_thing.x_mult}}, colour = G.C.FILTER})
                    table.insert(effects, {})
                end
            elseif context.playing_card_main then
                if config_thing.x_mult ~= 1 then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mod_x_mult, config_thing.x_mult}
        end,
        in_pool = function()
            for kk, vv in pairs(G.playing_cards) do
                if SMODS.has_enhancement(vv, 'm_glass') then
                    return true
                end
            end
            return false
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_satellite',
        card = {
            key = 'doj_satellite', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Satellite", 
            pos = {x=8,y=7},
            config = {dollars = 1}, 
            base = "D_9",
            is_joker = true,
            joker_rarity = 2,
            blueprint_incompat = true,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.end_of_round and (context.cardarea == G.hand) and not context.individual and not context.repetition and not context.blueprint then
                local planets_used = 0
                for k, v in pairs(G.GAME.consumeable_usage) do if v.set == 'Planet' then planets_used = planets_used + 1 end end
                if planets_used > 0 then
                    table.insert(effects, {
                        dollars = planets_used * config_thing.dollars,
                        card = card
                    })
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            local planets_used = 0
                for k, v in pairs(G.GAME.consumeable_usage) do if v.set == 'Planet' then planets_used = planets_used + 1 end end
            return {config_thing.dollars, planets_used * config_thing.dollars}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_scholar',
        card = {
            key = 'doj_scholar', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Scholar", 
            pos = {x=0,y=4},
            config = {chips = 20, mult = 4}, 
            base = "C_A",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.individual and (context.cardarea == G.play) and (card.area == G.play) and not context.end_of_round then
                local id = context.other_card:get_id()
                if id == 14 then
                    table.insert(effects, {
                        chips = config_thing.chips,
                        mult = config_thing.mult,
                        card = context.other_card
                    })
                end
            elseif context.get_id then
                return 14
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.chips, config_thing.mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_ride_the_bus',
        card = {
            key = 'doj_ride_the_bus', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Ride the Bus", 
            pos = {x=1,y=6},
            config = {mult = 0, mod_mult = 1}, 
            base = "C_T",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.before and (context.cardarea == G.play) then
                local faces = false
                for i = 1, #context.scoring_hand do
                    if context.scoring_hand[i]:is_face() then
                        faces = true
                        break
                    end
                end
                if faces then
                    local last_mult = config_thing.mult
                    config_thing.mult = 0
                    if last_mult > 0 then
                        card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_reset'), colour = G.C.FILTER})
                        
                    end
                else
                    config_thing.mult = config_thing.mult + config_thing.mod_mult
                    table.insert(effects, {})
                end
            elseif context.playing_card_main then
                if config_thing.mult > 0 then
                    table.insert(effects, {
                        mult = config_thing.mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mod_mult, config_thing.mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_yorick',
        card = {
            key = 'doj_yorick', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Yorick",
            pos = {x=5,y=8},
            soul_pos = {x=5,y=9},
            config = {x_mult = 1, mod_x_mult = 1, discards = 23, used_discards = 23}, 
            base = "H_3",
            is_joker = true,
            joker_rarity = 4,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.discard then
                if config_thing.used_discards <= 1 then
                    config_thing.used_discards = config_thing.discards
                    config_thing.x_mult = config_thing.x_mult + config_thing.mod_x_mult
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_xmult',vars={config_thing.x_mult}}, colour = G.C.RED, delay = 0.2})
                    table.insert(effects, {})
                else
                    config_thing.used_discards = config_thing.used_discards - 1
                    table.insert(effects, {})
                end
            elseif context.playing_card_main then
                if config_thing.x_mult ~= 1 then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mod_x_mult, config_thing.discards, config_thing.used_discards, config_thing.x_mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_superposition',
        card = {
            key = 'doj_superposition', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Superposition", 
            pos = {x=3,y=11},
            config = {dollars = 4}, 
            base = "S_A",
            is_joker = true,
            joker_rarity = 3,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if (#G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit) and context.poker_hands["Straight"] then
                    local aces = 0
                    for i = 1, #context.scoring_hand do
                        if context.scoring_hand[i]:get_id() == 14 then aces = aces + 1 end
                    end
                    if aces >= 1 then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        G.E_MANAGER:add_event(Event({
                            trigger = 'before',
                            delay = 0.0,
                            func = (function()
                                    local card = create_card('Tarot',G.consumeables, nil, nil, nil, nil, nil, 'vag')
                                    card:add_to_deck()
                                    G.consumeables:emplace(card)
                                    G.GAME.consumeable_buffer = 0
                                return true
                            end)}))
                        table.insert(effects, {
                            message = localize('k_plus_tarot'),
                            card = blueprint_card or card
                        })
                    end
                    table.insert(effects, {})
                end
            elseif context.get_id then
                return 14
            elseif context.does_score then
                return true
            end
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_ramen',
        card = {
            key = 'doj_ramen', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Ramen", 
            pos = {x=2,y=15},
            config = {x_mult = 2, mod_x_mult = 0.01}, 
            base = "H_2",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.discard and not context.blueprint and not card.ramen_killed then
                if config_thing.x_mult - config_thing.mod_x_mult <= 1 then 
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_eaten_ex'), colour = G.C.FILTER})
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                    func = function()
                            card.area:remove_card(card)
                            card:remove()
                            card = nil
                        return true; end}))
                else
                    config_thing.x_mult = config_thing.x_mult - config_thing.mod_x_mult
                    card_eval_status_text(card, 'extra', nil, nil, nil, {delay = 0.2, message = localize{type='variable',key='a_xmult_minus',vars={config_thing.mod_x_mult}}, colour = G.C.RED})
                    table.insert(effects, {})
                end
                
            elseif context.playing_card_main then
                if config_thing.x_mult ~= 1 then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.x_mult, config_thing.mod_x_mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_abstract',
        card = {
            key = 'doj_abstract', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Abstract Joker", 
            pos = {x=3,y=3},
            config = {mult = 3}, 
            base = "C_5",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if (G.jokers and G.jokers.cards and #G.jokers.cards or 0) > 0 then
                    table.insert(effects, {
                        mult = config_thing.mult * (G.jokers and G.jokers.cards and #G.jokers.cards or 0),
                        card = blueprint_card or card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mult, config_thing.mult * (G.jokers and G.jokers.cards and #G.jokers.cards or 0)}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_rough_gem',
        card = {
            key = 'doj_rough_gem', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Rough Gem", 
            pos = {x=9,y=7},
            config = {dollars = 1}, 
            base = "D_A",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config
            if context.individual and (context.cardarea == G.play) and (card.area == G.play) and not context.end_of_round then
                if context.other_card:is_suit("Diamonds") then
                    table.insert(effects, {
                        dollars = config_thing.dollars,
                        card = context.other_card
                    })
                end
            elseif context.is_suit then
                if ((context.is_suit == "Hearts") and next(find_joker('Smeared Joker'))) or (context.is_suit == "Diamonds") then
                    return true
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.dollars}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_stuntman',
        card = {
            key = 'doj_stuntman', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Stuntman", 
            pos = {x=8,y=6},
            config = {chips = 250, doj_hand_size = -2, doj_debuffed = false}, 
            base = "S_5",
            is_joker = true,
            joker_rarity = 3,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config
            if context.playing_card_main then
                table.insert(effects, {
                    chips = config_thing.chips,
                    card = context.other_card
                })
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.chips, -config_thing.doj_hand_size}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_lusty',
        card = {
            key = 'doj_lusty', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Lusty Joker", 
            pos = {x=7,y=1},
            config = {mult = 3}, 
            base = "H_3",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.individual and (context.cardarea == G.play) and (card.area == G.play) then
                if context.other_card:is_suit("Hearts") then
                    table.insert(effects, {
                        mult = config_thing.mult,
                        card = context.other_card
                    })
                end
            elseif context.is_suit then
                if ((context.is_suit == "Diamonds") and next(find_joker('Smeared Joker'))) or (context.is_suit == "Hearts") then
                    return true
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mult, localize("Hearts", 'suits_plural')}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_blue_joker',
        card = {
            key = 'doj_blue_joker', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Blue Joker", 
            pos = {x=7,y=10},
            config = {chips = 2}, 
            base = "S_4",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                table.insert(effects, {
                    chips = config_thing.chips * (G.deck and G.deck.cards and #G.deck.cards or 52),
                    card = blueprint_card or card
                })
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.chips, config_thing.chips * (G.deck and G.deck.cards and #G.deck.cards or 52)}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_family',
        card = {
            key = 'doj_family', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "The Family", 
            pos = {x=7,y=4},
            config = {x_mult = 4}, 
            base = "H_4",
            is_joker = true,
            joker_rarity = 3,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if next(context.poker_hands["Four of a Kind"]) then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.x_mult, localize('Four of a Kind', 'poker_hands')}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_order',
        card = {
            key = 'doj_order', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "The Order", 
            pos = {x=8,y=4},
            config = {x_mult = 3}, 
            base = "H_9",
            is_joker = true,
            joker_rarity = 3,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main or context.playing_card_hand then
                if next(context.poker_hands["Straight"]) then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.x_mult, localize('Straight', 'poker_hands')}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_flash',
        card = {
            key = 'doj_flash', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Flash Card", 
            pos = {x=0,y=15},
            config = {mult = 0, mod_mult = 2}, 
            base = "C_2",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.shop_reroll then
                config_thing.mult = config_thing.mult + config_thing.mod_mult
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_mult', vars = {config_thing.mult}}, colour = G.C.MULT})
                table.insert(effects, {})
            elseif context.playing_card_main then
                if config_thing.mult > 0 then
                    table.insert(effects, {
                        mult = config_thing.mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mod_mult, config_thing.mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_smiley_face',
        card = {
            key = 'doj_smiley_face', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Smiley Face", 
            pos = {x=6,y=15},
            config = {mult = 5}, 
            base = "C_5",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.individual and (context.cardarea == G.play) and (card.area == G.play) and not context.end_of_round then
                if context.other_card:is_face() then
                    table.insert(effects, {
                        mult = config_thing.mult,
                        card = context.other_card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_bootstraps',
        card = {
            key = 'doj_bootstraps', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Bootstraps", 
            pos = {x=9,y=8},
            config = {mult = 2, dollars = 5}, 
            base = "C_5",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                table.insert(effects, {
                    mult = config_thing.mult * math.floor((G.GAME and G.GAME.dollars or 0) / config_thing.dollars),
                    card = context.other_card
                })
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mult, config_thing.dollars, config_thing.mult * math.floor((G.GAME and G.GAME.dollars or 0) / config_thing.dollars)}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_faceless',
        card = {
            key = 'doj_faceless', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Faceless Joker", 
            pos = {x=1,y=11},
            config = {dollars = 5, faces = 3}, 
            base = "D_5",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.pre_discard then
                local face_cards = 0
                for k, v in ipairs(context.full_hand) do
                    if v:is_face() then face_cards = face_cards + 1 end
                end
                if face_cards >= config_thing.faces then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            ease_dollars(config_thing.dollars)
                            card_eval_status_text(blueprint_card or card, 'extra', nil, nil, nil, {message = localize('$')..config_thing.dollars,colour = G.C.MONEY, delay = 0.45})
                            return true
                        end}))
                    table.insert(effects, {})
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.dollars, config_thing.faces}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_reserved_parking',
        card = {
            key = 'doj_reserved_parking', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Reserved Parking", 
            pos = {x=6,y=13},
            config = {dollars = 1, odds = 2}, 
            base = "D_2",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config
            if context.individual and (context.cardarea == G.hand) and (card.area == G.play) and not context.end_of_round then
                if context.other_card:is_face() and (pseudorandom('parking') < G.GAME.probabilities.normal/config_thing.odds) then
                    table.insert(effects, {
                        dollars = config_thing.dollars,
                        card = context.other_card
                    })
                elseif context.other_card:is_face() then
                    table.insert(effects, {})
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.dollars, G.GAME.probabilities.normal, config_thing.odds}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_onyx_agate',
        card = {
            key = 'doj_onyx_agate', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Onyx Agate", 
            pos = {x=2,y=8},
            config = {mult = 7}, 
            base = "C_7",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config
            if context.individual and (context.cardarea == G.play) and (card.area == G.play) and not context.end_of_round then
                if context.other_card:is_suit("Clubs") then
                    table.insert(effects, {
                        mult = config_thing.mult,
                        card = context.other_card
                    })
                end
            elseif context.is_suit then
                if ((context.is_suit == "Spades") and next(find_joker('Smeared Joker'))) or (context.is_suit == "Clubs") then
                    return true
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_photograph',
        card = {
            key = 'doj_photograph', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Photograph", 
            pos = {x=2,y=13},
            config = {x_mult = 2}, 
            base = "H_K",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config
            if context.individual and (context.cardarea == G.play) and (card.area == G.play) and not context.end_of_round then
                local first_face = nil
                for i = 1, #context.scoring_hand do
                    if context.scoring_hand[i]:is_face() then first_face = context.scoring_hand[i]; break end
                end
                if context.other_card == first_face then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = context.other_card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.x_mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_banner',
        card = {
            key = 'doj_banner', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Banner", 
            pos = {x=1,y=2},
            config = {chips = 30}, 
            base = "S_3",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if G.GAME.current_round.discards_left > 0 then
                    table.insert(effects, {
                        chips = config_thing.chips * G.GAME.current_round.discards_left,
                        card = blueprint_card or card
                    })
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.chips}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_half',
        card = {
            key = 'doj_half', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Half Joker", 
            pos = {x=7,y=0},
            config = {mult = 20, cards = 3}, 
            base = "C_2",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if #context.full_hand <= config_thing.cards then
                    table.insert(effects, {
                        mult = config_thing.mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mult, config_thing.cards}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_space',
        card = {
            key = 'doj_space', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Space Joker", 
            pos = {x=3,y=5},
            config = {odds = 4}, 
            base = "S_4",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.before and (context.cardarea == G.play) then
                if pseudorandom('space') < (G.GAME.probabilities.normal/config_thing.odds) then
                    local text,disp_text = G.FUNCS.get_poker_hand_info(G.play.cards)
                    card_eval_status_text(blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_level_up_ex')})
                    level_up_hand(blueprint_card or card, text, nil, 1)
                    table.insert(effects, {})
                else
                    table.insert(effects, {})
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {G.GAME.probabilities.normal, config_thing.odds}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_arrowhead',
        card = {
            key = 'doj_arrowhead', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Arrowhead", 
            pos = {x=1,y=8},
            config = {chips = 50}, 
            base = "S_5",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config
            if context.individual and (context.cardarea == G.play) and (card.area == G.play) and not context.end_of_round then
                if context.other_card:is_suit("Spades") then
                    table.insert(effects, {
                        chips = config_thing.chips,
                        card = context.other_card
                    })
                end
            elseif context.is_suit then
                if ((context.is_suit == "Clubs") and next(find_joker('Smeared Joker'))) or (context.is_suit == "Spades") then
                    return true
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.chips}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_trio',
        card = {
            key = 'doj_trio', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "The Trio", 
            pos = {x=6,y=4},
            config = {x_mult = 3}, 
            base = "H_3",
            is_joker = true,
            joker_rarity = 3,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if next(context.poker_hands["Three of a Kind"]) then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.x_mult, localize('Three of a Kind', 'poker_hands')}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_greedy',
        card = {
            key = 'doj_greedy', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Greedy Joker", 
            pos = {x=6,y=1},
            config = {mult = 3}, 
            base = "D_3",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.individual and (context.cardarea == G.play) and (card.area == G.play) then
                if context.other_card:is_suit("Diamonds") then
                    table.insert(effects, {
                        mult = config_thing.mult,
                        card = context.other_card
                    })
                end
            elseif context.is_suit then
                if ((context.is_suit == "Hearts") and next(find_joker('Smeared Joker'))) or (context.is_suit == "Diamonds") then
                    return true
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mult, localize("Diamonds", 'suits_plural')}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_wrathful',
        card = {
            key = 'doj_wrathful', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Wrathful Joker", 
            pos = {x=8,y=1},
            config = {mult = 3}, 
            base = "S_3",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.individual and (context.cardarea == G.play) and (card.area == G.play) then
                if context.other_card:is_suit("Spades") then
                    table.insert(effects, {
                        mult = config_thing.mult,
                        card = context.other_card
                    })
                end
            elseif context.is_suit then
                if ((context.is_suit == "Clubs") and next(find_joker('Smeared Joker'))) or (context.is_suit == "Spades") then
                    return true
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mult, localize("Spades", 'suits_plural')}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_gluttonous',
        card = {
            key = 'doj_gluttonous', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Gluttonous Joker", 
            pos = {x=9,y=1},
            config = {mult = 3}, 
            base = "C_3",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.individual and (context.cardarea == G.play) and (card.area == G.play) then
                if context.other_card:is_suit("Clubs") then
                    table.insert(effects, {
                        mult = config_thing.mult,
                        card = context.other_card
                    })
                end
            elseif context.is_suit then
                if ((context.is_suit == "Spades") and next(find_joker('Smeared Joker'))) or (context.is_suit == "Clubs") then
                    return true
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mult, localize("Clubs", 'suits_plural')}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_acrobat',
        card = {
            key = 'doj_acrobat', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Acrobat", 
            pos = {x=2,y=1},
            config = {x_mult = 3}, 
            base = "H_3",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main and (G.GAME.current_round.hands_left == 0) then
                table.insert(effects, {
                    x_mult = config_thing.x_mult,
                    card = card
                })
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.x_mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_steel_joker',
        card = {
            key = 'doj_steel_joker', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Steel Joker", 
            pos = {x=7,y=2},
            config = {mod_x_mult = 0.2, steel_tally = 0}, 
            base = "H_2",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if config_thing.x_mult ~= 1 then
                    table.insert(effects, {
                        x_mult = 1 + config_thing.steel_tally * config_thing.mod_x_mult,
                        card = card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mod_x_mult, 1 + config_thing.steel_tally * config_thing.mod_x_mult}
        end,
        in_pool = function()
            for kk, vv in pairs(G.playing_cards) do
                if SMODS.has_enhancement(vv, 'm_steel') then
                    return true
                end
            end
            return false
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_cloud_9',
        card = {
            key = 'doj_cloud_9', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Cloud 9", 
            pos = {x=7,y=12},
            config = {mod_dollars = 1, nine_tally = 0}, 
            base = "D_9",
            is_joker = true,
            joker_rarity = 2,
            blueprint_incompat = true,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.end_of_round and (context.cardarea == G.hand) and not context.individual and not context.repetition and not context.blueprint then
                table.insert(effects, {
                    dollars = config_thing.mod_dollars *  config_thing.nine_tally,
                    card = card
                })
            elseif context.get_id then
                return 9
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mod_dollars, config_thing.mod_dollars *  config_thing.nine_tally}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_fortune_teller',
        card = {
            key = 'doj_fortune_teller', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Fortune Teller", 
            pos = {x=7,y=5},
            config = {mod_mult = 1}, 
            base = "C_2",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.using_consumeable and (context.using_consumeable.ability.set == "Tarot") and not context.blueprint then
                G.E_MANAGER:add_event(Event({
                    func = function() card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_mult',vars={(G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.tarot or 0)}}}); return true
                    end}))
            elseif context.playing_card_main then
                if (G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.tarot or 0) >= 0 then
                    table.insert(effects, {
                        mult = config_thing.mod_mult * G.GAME.consumeable_usage_total.tarot,
                        card = blueprint_card or card
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mod_mult, config_thing.mod_mult * (G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.tarot or 0)}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_bull',
        card = {
            key = 'doj_bull', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Bull", 
            pos = {x=7,y=14},
            config = {chips = 2}, 
            base = "S_2",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                table.insert(effects, {
                    chips = config_thing.chips * (G.GAME and G.GAME.dollars or 0),
                    card = context.other_card
                })
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.chips, config_thing.chips * (G.GAME and G.GAME.dollars or 0)}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_trousers',
        card = {
            key = 'doj_trousers', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Spare Trousers", 
            pos = {x=4,y=15},
            config = {mult = 0, mod_mult = 2}, 
            base = "C_4",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if config_thing.mult > 0 then
                    table.insert(effects, {
                        mult = config_thing.mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.before and (context.cardarea == G.play) then
                config_thing.mult = config_thing.mult + config_thing.mod_mult
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex'), colour = G.C.RED})
                table.insert(effects, {})
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mod_mult, localize('Two Pair', 'poker_hands'), config_thing.mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_red_card',
        card = {
            key = 'doj_red_card', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Red Card", 
            pos = {x=7,y=11},
            config = {mult = 0, mod_mult = 3}, 
            base = "C_3",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                if config_thing.mult > 0 then
                    table.insert(effects, {
                        mult = config_thing.mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.skipping_booster and not context.blueprint then
                config_thing.mult = config_thing.mult + config_thing.mod_mult
                G.E_MANAGER:add_event(Event({
                    func = function() 
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = localize{type = 'variable', key = 'a_mult', vars = {config_thing.mod_mult}},
                            colour = G.C.RED,
                            delay = 0.45, 
                            card = self
                        }) 
                        return true
                    end}))
                table.insert(effects, {})
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.mod_mult, config_thing.mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_square',
        card = {
            key = 'doj_square', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Square Joker", 
            pos = {x=9,y=11},
            config = {chips = 0, mod_chips = 4}, 
            base = "S_4",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                table.insert(effects, {
                    chips = config_thing.chips,
                    card = blueprint_card or card
                })
            elseif context.before and (context.cardarea == G.play) and (#context.full_hand == 4) and not context.blueprint then
                config_thing.chips = config_thing.chips + config_thing.mod_chips
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex'), colour = G.C.CHIPS})
                table.insert(effects, {})
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.chips, config_thing.mod_chips}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_troubadour',
        card = {
            key = 'doj_troubadour', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Troubadour", 
            pos = {x=0,y=2},
            config = {doj_hands = -1, doj_hand_size = 2, doj_debuffed = false}, 
            base = "S_2",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.doj_hand_size, -config_thing.doj_hands}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_misprint',
        card = {
            key = 'doj_misprint', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Misprint", 
            pos = {x=6,y=2},
            config = {min = 0, max = 24}, 
            base = "C_Q",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config
            if context.playing_card_main then
                local temp_Mult = pseudorandom('misprint', config_thing.min, config_thing.max)
                table.insert(effects, {
                    mult = temp_Mult,
                    card = blueprint_card or card
                })
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_delayed_grat',
        card = {
            key = 'doj_delayed_grat', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Delayed Gratification", 
            pos = {x=4,y=3},
            config = {dollars = 2}, 
            base = "D_6",
            is_joker = true,
            joker_rarity = 1,
            blueprint_incompat = true,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.end_of_round and (context.cardarea == G.hand) and not context.individual and not context.repetition and not context.blueprint then
                if (G.GAME.current_round.discards_used == 0) and (G.GAME.current_round.discards_left > 0) then
                    table.insert(effects, {
                        dollars = config_thing.dollars * G.GAME.current_round.discards_left,
                        card = card
                    })
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.dollars}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_seltzer',
        card = {
            key = 'doj_seltzer', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Seltzer", 
            pos = {x=3,y=15},
            config = {hands = 10}, 
            base = "S_T",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.repetition and (card.area == G.play) and (context.cardarea == G.play) then
                local special_table = {blueprint_card or card}
                if reps_i ~= 1 then
                    for j = 1, #reps[reps_i].cards do
                        table.insert(special_table, reps[reps_i].cards[j])
                    end
                end
                table.insert(effects, {
                    message = localize('k_again_ex'),
                    repetitions = 1,
                    cards = special_table
                })
            elseif context.after and ((context.cardarea == G.play) or (context.cardarea == G.hand)) and not context.blueprint then
                config_thing.hands = config_thing.hands - 1
                if (context.cardarea == G.hand) and (config_thing.hands <= 0) then
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_drank_ex'), colour = G.C.FILTER})
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                    func = function()
                            card.area:remove_card(card)
                            card:remove()
                            card = nil
                        return true; end}))
                elseif (config_thing.hands > 0) then
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = tostring(config_thing.hands), colour = G.C.FILTER})
                    delay(0.1)
                    table.insert(effects, {})
                end
            elseif (context.destroying_card == card) and not context.blueprint and (context.cardarea == G.play) then
                if (config_thing.hands <= 1) and not context.blueprint then
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_drank_ex'), colour = G.C.FILTER})
                    return true
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.hands}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_drunkard',
        card = {
            key = 'doj_drunkard', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Drunkard", 
            pos = {x=1,y=1},
            config = {doj_discards = 1, doj_debuffed = false}, 
            base = "S_3",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.doj_discards}
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_sock_and_buskin',
        card = {
            key = 'doj_sock_and_buskin', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "Sock and Buskin", 
            pos = {x=3,y=1},
            config = {}, 
            base = "S_J",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.repetition and (card.area == G.play) and (context.cardarea == G.play) then
                local special_table = {blueprint_card or card}
                if reps_i ~= 1 then
                    for j = 1, #reps[reps_i].cards do
                        table.insert(special_table, reps[reps_i].cards[j])
                    end
                end
                if context.other_card:is_face() then
                    table.insert(effects, {
                        message = localize('k_again_ex'),
                        repetitions = 1,
                        cards = special_table
                    })
                end
            elseif context.is_face then
                return true
            elseif context.does_score then
                return true
            end
        end
    }

    pc_add_cross_mod_card {
        key = 'doj_tribe',
        card = {
            key = 'doj_tribe', 
            unlocked = true, 
            discovered = true, 
            atlas = 'Joker', 
            cost = 1, 
            name = "The Tribe", 
            pos = {x=9,y=4},
            config = {x_mult = 2}, 
            base = "H_5",
            is_joker = true,
            joker_rarity = 3,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main or context.playing_card_hand then
                if next(context.poker_hands["Flush"]) then
                    table.insert(effects, {
                        x_mult = config_thing.x_mult,
                        card = blueprint_card or card
                    })
                end
            elseif context.does_score then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.x_mult, localize('Flush', 'poker_hands')}
        end
    }

    doj_joker_pools = {{}, {}, {}, {}}
    for i, j in pairs(G.P_TRADING) do
        if j.is_joker then
            table.insert(doj_joker_pools[j.joker_rarity], j.key)
        end
    end
    for i, j in ipairs(doj_joker_pools) do
        table.sort(j)
    end
end

function get_joker_key(rarity)
    local rarity_pick = rarity or pseudorandom(pseudoseed('doj_joker_rarity_pick'))
    local pool = {}
    if rarity_pick < 0.7 then
        pool = doj_joker_pools[1]
    elseif rarity_pick < 0.95 then
        pool = doj_joker_pools[2]
    elseif rarity_pick < 0.995 then
        pool = doj_joker_pools[3]
    else
        pool = doj_joker_pools[4]
    end
    local new_pool = {}
    for i = 1, #pool do
        local j = G.P_TRADING[pool[i]]
        local i = pool[i]
        if (not j.in_pool or j:in_pool()) and (not pc_cross_mod_cards[i] or not pc_cross_mod_cards[i].in_pool or pc_cross_mod_cards[i].in_pool()) then
            local joker_key = string.sub(i, 3)
            if not G.GAME.banned_keys[joker_key] then
                table.insert(new_pool, j)
            end
        end
    end
    local key = pseudorandom_element(new_pool, pseudoseed('joker_trading'))
    return key.key
end

SMODS.Back {
    key = 'deck_of_jokes',
    loc_txt = {
        name = "Deck of Jokes",
        text = {
            "Start with {C:attention}40{}",
            "{C:dark_edition}Jokers{} in {C:attention}deck{}"
        }
    },
    atlas = "decks",
    pos = {x = 0, y = 0},
    name = "Deck of Jokes",
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for i = #G.playing_cards, 1, -1 do
                    G.playing_cards[i]:remove()
                end
                for i = 1, 40 do
                    local key = G.P_TRADING[get_joker_key()]
                    local _card = Card(G.deck.T.x, G.deck.T.y, G.CARD_W, G.CARD_H, G.P_CARDS[key.base], G.P_CENTERS['m_pc_trading'], {playing_card = G.playing_card})
                    _card.force_trading = key.key
                    _card:set_ability(G.P_CENTERS["m_pc_trading"])
                    _card:set_sprites(_card.config.center)
                    G.deck:emplace(_card)
                    table.insert(G.playing_cards, _card)
                end
            return true
            end
        }))
    end
}

SMODS.Back {
    key = 'final_draft',
    loc_txt = {
        name = "Final Draft Deck",
        text = {
            "Start with {C:attention}5{}",
            "extra {C:red}Rare{} {C:dark_edition}Jokers{}",
            "in {C:attention}deck{}"
        }
    },
    atlas = "decks",
    pos = {x = 1, y = 0},
    name = "Final Draft Deck",
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for i = 1, 5 do
                    local key = G.P_TRADING[get_joker_key(0.99)]
                    local _card = Card(G.deck.T.x, G.deck.T.y, G.CARD_W, G.CARD_H, G.P_CARDS[key.base], G.P_CENTERS['m_pc_trading'], {playing_card = G.playing_card})
                    _card.force_trading = key.key
                    _card:set_ability(G.P_CENTERS["m_pc_trading"])
                    _card:set_sprites(_card.config.center)
                    G.deck:emplace(_card)
                    table.insert(G.playing_cards, _card)
                end
            return true
            end
        }))
    end
}

SMODS.Tarot {
    key = 'cool_judgement',
    atlas = "sprites",
    pos = {x = 0, y = 0},
    config = {max_highlighted = 1},
    use = function(self, card, area, copier)
        local used_tarot = copier or card
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            play_sound('tarot1')
            used_tarot:juice_up(0.3, 0.5)
            return true end }))
        for i=1, #G.hand.highlighted do
            local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
        end
        delay(0.2)
        for i=1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                local key = get_joker_key()
                G.hand.highlighted[i].force_trading = key
                G.hand.highlighted[i]:set_ability(G.P_CENTERS["m_pc_trading"])
                G.hand.highlighted[i]:set_base(G.P_CARDS[G.P_TRADING[key].base])
                G.hand.highlighted[i]:set_sprites(G.hand.highlighted[i].config.center)
                return true 
            end }))
        end
        delay(0.6)
        for i=1, #G.hand.highlighted do
            local percent = 0.85 + (i-0.999)/(#G.hand.highlighted-0.998)*0.3
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('tarot2', percent, 0.6);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
        end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
        delay(0.5)
    end,
    loc_vars = function(self, info_queue, card)
        return {vars = {card and card.ability.consumeable.max_highlighted or 1} }
    end
}

SMODS.Booster {
    key = 'paper_buffoon_normal_1',
    atlas = 'sprites',
    group_key = 'k_paper_buffoon_pack',
    loc_txt = {
        name = "Paper Buffoon Pack",
        text = {
            "Choose {C:attention}#1#{} of up to",
            "{C:attention}#2#{C:dark_edition} Joker{} cards to",
            "add to your deck"
        }
    },
    weight = 4,
    name = "Paper Buffoon Pack",
    pos = {x = 1, y = 0},
    config = {extra = 4, choose = 1, name = "Paper Buffoon Pack"},
    create_card = function(self, card)
        local key = G.P_TRADING[get_joker_key()]
        local _card = Card(G.deck.T.x, G.deck.T.y, G.CARD_W, G.CARD_H, G.P_CARDS[key.base], G.P_CENTERS['m_pc_trading'], {playing_card = G.playing_card})
        _card.force_trading = key.key
        _card:set_ability(G.P_CENTERS["m_pc_trading"])
        _card:set_sprites(_card.config.center)
        local edition = poll_edition('trading_edition'..G.GAME.round_resets.ante, 1, true)
        _card:set_edition(edition)
        _card:set_seal(SMODS.poll_seal({mod = 3}))
        return _card
    end,
    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, HEX('bebebe'))
        ease_background_colour{new_colour = HEX('bebebe'), special_colour = G.C.BLACK, contrast = 2}
    end,
}

local old_floating_sprite = SMODS.DrawSteps['floating_sprite'].func
SMODS.DrawSteps['floating_sprite'].func = function(self)
    if self.ability and self.ability.trading and self.ability.trading.soul_pos and  (self.config.center.discovered or self.bypass_discovery_center) then
        local scale_mod = 0.07 + 0.02*math.sin(1.8*G.TIMERS.REAL) + 0.00*math.sin((G.TIMERS.REAL - math.floor(G.TIMERS.REAL))*math.pi*14)*(1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL)))^3
        local rotate_mod = 0.05*math.sin(1.219*G.TIMERS.REAL) + 0.00*math.sin((G.TIMERS.REAL)*math.pi*5)*(1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL)))^2

        if type(self.ability.trading.soul_pos.draw) == 'function' then
            self.ability.trading.soul_pos.draw(self, scale_mod, rotate_mod)
        elseif self.ability.trading and (self.ability.trading.name == 'Hologram') then
            self.hover_tilt = self.hover_tilt*1.5
            self.children.floating_sprite:draw_shader('hologram', nil, self.ARGS.send_to_shader, nil, self.children.center, 2*scale_mod, 2*rotate_mod)
            self.hover_tilt = self.hover_tilt/1.5
        else
            self.children.floating_sprite:draw_shader('dissolve',0, nil, nil, self.children.center,scale_mod, rotate_mod,nil, 0.1 + 0.03*math.sin(1.8*G.TIMERS.REAL),nil, 0.6)
            self.children.floating_sprite:draw_shader('dissolve', nil, nil, nil, self.children.center, scale_mod, rotate_mod)
        end
        if self.edition then 
            for k, v in pairs(G.P_CENTER_POOLS.Edition) do
                if v.apply_to_float then
                    if self.edition[v.key:sub(3)] then
                        self.children.floating_sprite:draw_shader(v.shader, nil, nil, nil, self.children.center, scale_mod, rotate_mod)
                    end
                end
            end
        end
    end
    old_floating_sprite(self)
end

local old_always_scores = SMODS.always_scores
function SMODS.always_scores(card)
    local splashed = false
    for i = 1, #G.play.cards do
        local card = G.play.cards[i]
            if card and card.ability and card.ability.trading and (card.ability.trading.name == "Splash") and not card.debuff then
                splashed = true
            end
    end
    if splashed then
        return true
    else
        return old_always_scores(card)
    end
end

----------------------------------------------
------------MOD CODE END----------------------