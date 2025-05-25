--- STEAMODDED HEADER
--- MOD_NAME: Deck of Jokes
--- MOD_ID: DeckOfJokes
--- PREFIX: doj
--- MOD_AUTHOR: [mathguy]
--- MOD_DESCRIPTION: Deck of Jokers
--- DEPENDENCIES: [CustomCards]
--- VERSION: 1.0.2
----------------------------------------------
------------MOD CODE -------------------------

SMODS.Atlas({ key = "decks", atlas_table = "ASSET_ATLAS", path = "decks.png", px = 71, py = 95})

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
    old_ability(self, center, initial, delay_sprites)
    local hand_size2 = not self.debuff and self.ability and self.ability.trading and self.ability.trading.config.doj_hand_size or 0
    if self.area == G.hand then
        if hand_size1 ~= hand_size2 then
            local change = hand_size2 - hand_size1
            G.hand.config.real_card_limit = (G.hand.config.real_card_limit or G.hand.config.card_limit) + change
            G.hand.config.card_limit = math.max(0, G.hand.config.real_card_limit)
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
        self.T.h = self.T.h / 0.7
        self.T.w = self.T.w / 0.7
    end
end

local old_is_suit = Card.is_suit
function Card:is_suit(suit, bypass_debuff, flush_calc)
    local result = old_is_suit(self, suit, bypass_debuff, flush_calc)
    local smearedness = false
    if G.play and G.play.cards and G.play.cards[1] then
        for i = 1, #G.play.cards do
            local card = G.play.cards[i]
            if card and card.ability and card.ability.trading and (card.ability.trading.name == "Smeared Joker") and (not card.debuff or non_debuff) then
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
        local has_four_fingers = nil
        for i = 1, #hand do
            if hand[i].ability.trading and (hand[i].ability.trading.name == "Four Fingers") and not hand[i].debuff then
                has_four_fingers = true
                break
            end
        end
        if not has_four_fingers then
            return {}
        end
        return get_straight(hand, 4, not not next(SMODS.find_card('j_shortcut')))
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
    if name == "Showman" then
        local showmen = {}
        for i = 1, #G.playing_cards do
            local card = G.playing_cards[i]
            if card and card.ability and card.ability.trading and (card.ability.trading.name == "Showman") and (not card.debuff or non_debuff) then
                table.insert(showmen, card)
            end
        end
        return showmen
    elseif name == "Astronomer" then
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
    if key == "j_ring_master" then
        local showmen = {}
        for i = 1, #G.playing_cards do
            local card = G.playing_cards[i]
            if card and card.ability and card.ability.trading and (card.ability.trading.name == "Showman") and (not card.debuff or count_debuffed) then
                table.insert(showmen, card)
            end
        end
        return showmen
    elseif key == "j_astronomer" then
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
            base = "C_A",
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
            base = "H_A",
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
            base = "S_A",
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
            base = "D_A",
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
            base = "D_A",
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
            base = "D_A",
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
            base = "S_A",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.before and ((context.cardarea == G.play) or (context.cardarea == G.hand)) and next(context.poker_hands['Straight']) and not context.blueprint then
                config_thing.chips = config_thing.chips + config_thing.mod_chips
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
            base = "H_A",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.using_consumeable and (context.using_consumeable.ability.set == "Planet") and not context.blueprint then
                config_thing.x_mult = config_thing.x_mult + config_thing.mod_x_mult
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
            base = "D_A",
            is_joker = true,
            joker_rarity = 1,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.discard and (context.other_card:get_id() == G.GAME.current_round.mail_card.id) then
                ease_dollars(config_thing.dollars)
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
            base = "H_A",
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
                    return nil, true
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
            base = "D_A",
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
            base = "S_A",
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
            base = "H_A",
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
            return {config_thing.mod_chips, config_thing.chips}
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
            base = "S_A",
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
            base = "D_A",
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
            base = "D_A",
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
            base = "S_A",
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
            base = "S_A",
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
            base = "H_A",
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
            base = "S_A",
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
            base = "S_A",
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
            base = "H_A",
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
            base = "S_A",
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
            base = "S_A",
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
            base = "C_A",
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
            base = "C_A",
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
            base = "C_A",
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
                    if not next(rank2) then
                        rank2.nominal = -999
                    end
                    if rank.nominal >= rank2.nominal then 
                        card_ = G.hand.cards[i]
                        rank = rank2
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
            base = "H_A",
            is_joker = true,
            joker_rarity = 3,
        },
        calculate = function(card, effects, context, reps, blueprint_card)
            local config_thing = card.ability.trading.config 
            if context.selling_card and not context.blueprint then
                config_thing.x_mult = config_thing.x_mult + config_thing.mod_x_mult
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex'), colour = G.C.FILTER})
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
            base = "S_A",
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
            base = "H_A",
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
            base = "S_A",
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
            base = "S_A",
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
            base = "D_A",
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
            base = "C_A",
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
            base = "D_Q",
            is_joker = true,
            joker_rarity = 2,
        },
        calculate = function(card, effects, context, reps, blueprint_card, reps_i)
            local config_thing = card.ability.trading.config 
            if context.before and (context.cardarea == G.play) then
                local faces = 0
                for i = 1, #context.scoring_hand do
                    if context.scoring_hand[i]:is_face() then 
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
            base = "S_A",
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
            base = "H_A",
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
            base = "S_A",
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
            base = "H_A",
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
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_xmult', vars = {config_thing.x_mult}}, colour = G.C.FILTER})
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
            base = "C_A",
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
            base = "S_A",
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
            base = "S_A",
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
            base = "H_A",
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
            base = "S_A",
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
            base = "S_A",
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
            base = "C_A",
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
            base = "H_A",
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
            base = "D_A",
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
            base = "C_A",
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
            base = "S_A",
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
            base = "C_A",
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
            base = "H_A",
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
            base = "H_A",
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
                    end
                else
                    config_thing.x_mult = config_thing.x_mult + config_thing.mod_x_mult
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
            base = "C_A",
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
            base = "C_A",
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
            base = "D_A",
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

    doj_joker_pools = {{}, {}, {}, {}}
    for i, j in pairs(G.P_TRADING) do
        if j.is_joker then
            table.insert(doj_joker_pools[j.joker_rarity], j.key)
        end
    end
end

function get_joker_key()
    local rarity_pick = pseudorandom('doj_joker_rarity_pick')
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
            table.insert(new_pool, j)
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
                    _card.ability.trading = copy_table(key)
                    _card:set_sprites(_card.config.center)
                    G.deck:emplace(_card)
                    table.insert(G.playing_cards, _card)
                end
            return true
            end
        }))
    end
}

local old_floating_sprite = SMODS.DrawSteps['floating_sprite'].func
SMODS.DrawSteps['floating_sprite'].func = function(self)
    if self.ability and self.ability.trading and self.ability.trading.soul_pos and  (self.config.center.discovered or self.bypass_discovery_center) then
        local scale_mod = 0.07 + 0.02*math.sin(1.8*G.TIMERS.REAL) + 0.00*math.sin((G.TIMERS.REAL - math.floor(G.TIMERS.REAL))*math.pi*14)*(1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL)))^3
        local rotate_mod = 0.05*math.sin(1.219*G.TIMERS.REAL) + 0.00*math.sin((G.TIMERS.REAL)*math.pi*5)*(1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL)))^2

        if type(self.ability.trading.soul_pos.draw) == 'function' then
            self.ability.trading.soul_pos.draw(self, scale_mod, rotate_mod)
        elseif self.ability.name == 'Hologram' then
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

----------------------------------------------
------------MOD CODE END----------------------