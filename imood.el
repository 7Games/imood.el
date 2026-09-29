;;; imood.el --- imood.com through emacs -*- lexical-binding: t; -*-

;;; Author: Benjamin (svn)
;;; License: UNLICENSE (https://unlicense.org/)

;;; Commentary:

;; Update, and view moods through Emacs

;;; Code:

(require 'dom)
(require 'url-util)

(defvar imood//email "nil")
(defvar imood//password "nil")

;; Yes these are all the moods, as of 2026-09-28
;; NOTE: Update every once in a while (imood//get-mood-list)
(defconst imood//moods '("abandoned" "abnormal" "abused" "accepted" "accomplished" "achy"
                         "active" "addicted" "adored" "adventurous" "affectionate" "aggravated"
                         "aggressive" "agitated" "alienated" "alive" "alluring" "alone" "aloof"
                         "alright" "amazed" "amazing" "ambitious" "ambivalent" "amorous" "amused"
                         "angelic" "angry" "angsty" "annoyed" "annoying" "antisocial" "antsy"
                         "anxious" "apathetic" "apologetic" "appalled" "appreciated" "appreciative"
                         "apprehensive" "argumentative" "aroused" "artistic" "ashamed" "asleep"
                         "astonished" "astounded" "athletic" "attractive" "audacious" "awake"
                         "awesome" "awestruck" "awful" "awkward" "bad" "baffled" "balanced"
                         "bashful" "beaming" "beat" "beautiful" "befuddled" "belittled"
                         "belligerent" "bemused" "betrayed" "better" "bewildered" "bewitched" "big"
                         "bipolar" "bitchy" "bitter" "bittersweet" "bizarre" "blah" "blank"
                         "blasphemous" "bleak" "bleh" "blessed" "blind" "blissful" "bloated" "blonde"
                         "blotto" "blue" "boastful" "boisterous" "bold" "bonkers" "bootylicious" "bored"
                         "bothered" "bouncy" "boyish" "braindead" "bratty" "brave" "breathless" "bright"
                         "brilliant" "broke" "broken" "broken-hearted" "bruised" "bubbly" "bummed"
                         "burdened" "burned" "burned-out" "businesslike" "busy" "buzzed" "caffeinated"
                         "callous" "calm" "cantankerous" "capricious" "captivated" "carefree" "careless"
                         "catatonic" "catty" "cautious" "cavalier" "celebratory" "challenged" "changed"
                         "chaotic" "charitable" "charmed" "charming" "cheated" "cheeky" "cheerful" "cheery"
                         "cheesy" "cherished" "childish" "chilled" "chillin" "chipper" "christmasy" "classy"
                         "claustrophobic" "clean" "clever" "clingy" "clueless" "clumsy" "cocky" "cold"
                         "colorful" "comfortable" "comforted" "compassionate" "competitive" "complacent"
                         "complete" "complicated" "concerned" "confident" "confined" "conflicted" "confused"
                         "confuzzled" "congested" "connected" "constipated" "contemplative" "content"
                         "controlled" "cool" "copacetic" "corny" "cosmic" "courageous" "coy" "cozy" "crabby"
                         "crafty" "crampy" "cranky" "crappy" "crazy" "creative" "creepy" "crestfallen" "cruel"
                         "crummy" "crushed" "crusty" "cuddly" "cunning" "curious" "cursed" "cute" "cynical"
                         "damned" "dancy" "dandy" "dangerous" "daring" "dark" "daunted" "dazed" "dead"
                         "decadent" "decaffeinated" "deceived" "decent" "deep" "defeated" "defensive"
                         "defiant" "deficient" "deflated" "dejected" "delicious" "delighted" "delirious"
                         "delusional" "demented" "demonic" "demure" "dense" "depraved" "depressed" "deprived"
                         "deranged" "deserted" "desolate" "desperate" "despondent" "destroyed" "destructive"
                         "detached" "determined" "devastated" "devilish" "devious" "devoted" "different"
                         "dirty" "disappointed" "discarded" "discombobulated" "disconnected" "discouraged"
                         "diseased" "disenchanted" "disengaged" "disgruntled" "disgusted" "disillusioned"
                         "dismayed" "disoriented" "disrespected" "dissociated" "distant" "distracted"
                         "distraught" "distressed" "disturbed" "ditched" "ditzy" "divine" "dizzy" "dodgy"
                         "domestic" "dominant" "done" "doomed" "dorky" "doubtful" "dour" "down" "drained"
                         "dramatic" "dreamy" "driven" "drowsy" "drunk" "dry" "ducky" "dull" "dumb" "dumbfounded"
                         "dysmorphic" "dysphoric" "eager" "eccentric" "ecstatic" "edgy" "eek!" "effervescent"
                         "eh" "elated" "electric" "electrified" "embarrassed" "emotional" "emotionless"
                         "empathetic" "empowered" "empty" "enamored" "enchanted" "encouraged" "energetic"
                         "energized" "engaged" "enigmatic" "enlightened" "enraged" "enraptured" "entertained"
                         "enthralled" "enthusiastic" "envious" "epic" "erotic" "erratic" "esoteric" "ethereal"
                         "euphoric" "evil" "exasperated" "excellent" "excited" "excluded" "exhausted" "existential"
                         "exotic" "expectant" "experimental" "explosive" "exuberant" "fabulous" "faded" "faithful"
                         "fake" "famished" "fancy" "fantastic" "fat" "fatigued" "fed up" "feisty" "feline" "feral"
                         "festive" "fetching" "feverish" "fickle" "fidgety" "fine" "finite" "fired up" "fixated"
                         "flabbergasted" "flashy" "flattered" "flighty" "flippant" "flirty" "fluffy" "flummoxed"
                         "flustered" "focused" "foggy" "foolish" "forgetful" "forgiving" "forgotten" "forlorn"
                         "forsaken" "fortuitous" "found" "foxy" "fragile" "frantic" "frazzled" "freaked" "freaky"
                         "free" "freezing" "fresh" "friendly" "friendzoned" "frightened" "frisky" "frivolous"
                         "frozen" "fruity" "frumpy" "frustrated" "fulfilled" "full" "fun" "funky" "funny" "furious"
                         "fuzzy" "gay" "geeked" "geeky" "gelatinous" "generous" "genki" "ghetto" "giddy" "giggly"
                         "girly" "glad" "glamorous" "gleeful" "glittery" "gloomy" "glorious" "glowing" "glum"
                         "good" "goofy" "gorgeous" "gothic" "grand" "grateful" "great" "greedy" "groggy" "groovy"
                         "gross" "grouchy" "grounded" "grr" "grumpy" "guilty" "hangry" "hanukkahy" "happy"
                         "hardcore" "hated" "hateful" "haunted" "headachy" "healthy" "heartbroken" "heavenly"
                         "hella good" "helpful" "helpless" "heroic" "hesitant" "high" "hip" "historical" "hollow"
                         "holy" "homesick" "hopeful" "hopeless" "hormonal" "horny" "horrible" "horrified" "hostile"
                         "hot" "hotheaded" "humbled" "humiliated" "hungover" "hungry" "hurt" "hyggelig" "hyper"
                         "hyperactive" "hypocritical" "hysterical" "icky" "idiotic" "ignorant" "ignored" "ill"
                         "illuminated" "imaginative" "immature" "impatient" "impish" "important" "impressed"
                         "in denial" "in love" "in pain" "inadequate" "incomplete" "incredible" "incredulous"
                         "indecisive" "independent" "indifferent" "indulgent" "industrious" "infatuated" "inferior"
                         "infinite" "infuriated" "innocent" "inquisitive" "insane" "insatiable" "insecure"
                         "insightful" "insignificant" "inspired" "insulted" "intellectual" "intelligent"
                         "interested" "intimidated" "intoxicated" "intrepid" "intrigued" "introspective"
                         "inventive" "invincible" "invisible" "irate" "irked" "irreverent" "irritable" "irritated"
                         "isolated" "itchy" "jaded" "jazzed" "jealous" "jetlagged" "jiggy" "jinxed" "jittery"
                         "jocund" "jolly" "jovial" "joyful" "jubilant" "jumbled" "jumpy" "kawaii" "keen" "kinky"
                         "klutzy" "knackered" "knowledgeable" "kooky" "lackadaisical" "lame" "lazy" "leery"
                         "left out" "lethargic" "liberated" "lifeless" "listless" "livid" "lonely" "longing"
                         "loopy" "lost" "loud" "lousy" "lovable" "loved" "lovely" "lovesick" "lovestruck" "loving"
                         "loyal" "lucky" "lustful" "mad" "magical" "malicious" "manic" "manipulative" "manly"
                         "marvelous" "masochistic" "mature" "mean" "medicated" "mediocre" "megalomaniacal" "meh"
                         "melancholy" "mellow" "melodramatic" "mercurial" "merry" "messy" "mid" "miffed"
                         "misanthropic" "mischievous" "miserable" "misplaced" "misunderstood" "mixed" "moodless"
                         "moody" "mopey" "morbid" "morose" "mortified" "motivated" "mushy" "musical" "mysterious"
                         "mystic" "mystified" "naive" "naked" "narcissistic" "nasty" "natural" "naughty" "nauseous"
                         "needy" "neglected" "nerdy" "nervous" "neurotic" "neutral" "nice" "nifty" "nonchalant"
                         "normal" "nostalgic" "nothing" "numb" "nurturing" "nutty" "oblivious" "obnoxious" "obscene"
                         "obsessed" "odd" "offended" "ok" "old" "olympic" "optimistic" "organized" "orgasmic"
                         "ornery" "outgoing" "outraged" "overheated" "overjoyed" "overloaded" "overreactive"
                         "overstimulated" "overwhelmed" "overworked" "oy" "pained" "pampered" "panicked" "paranoid"
                         "passionate" "passive" "pathetic" "patient" "patriotic" "peaceful" "peachy" "peeved"
                         "pensive" "peppy" "perfect" "perky" "perplexed" "perturbed" "perverted" "pessimistic"
                         "petrified" "petty" "philosophical" "pi" "pink" "pissed" "pissed off" "pissy" "placid"
                         "playful" "pleasant" "pleased" "pmsy" "poetic" "pooped" "popular" "positive" "pouty"
                         "powerful" "powerless" "precious" "predatory" "pregnant" "preppy" "pressured" "pretty"
                         "productive" "protective" "proud" "provocative" "psyched" "psychedelic" "psychic"
                         "psycho" "psychotic" "pumped" "punchy" "punk" "punky" "pure" "puzzled" "queasy" "queer"
                         "quiet" "quirky" "quixotic" "rad" "radiant" "rambunctious" "random" "randy" "raunchy"
                         "ready" "rebellious" "reborn" "recalcitrant" "reclusive" "reflective" "refreshed" "regal"
                         "regretful" "rejected" "rejuvenated" "relaxed" "relieved" "religious" "reluctant" "reminiscent"
                         "renewed" "repulsed" "resentful" "reserved" "resigned" "resilient" "resolute" "resourceful"
                         "responsible" "rested" "restless" "retro" "rich" "ridiculed" "righteous" "robotic" "rofl"
                         "romantic" "rowdy" "royal" "rude" "rushed" "sad" "sadistic" "safe" "salty" "sane" "sapphic"
                         "sappy" "sarcastic" "sardonic" "sassy" "sated" "satisfied" "saturnine" "saucy" "scandalous"
                         "scared" "scattered" "schizophrenic" "scholarly" "scorned" "screwed" "secretive" "secure"
                         "sedated" "seductive" "seen" "self-conscious" "selfish" "sensitive" "sensual" "sentimental"
                         "serene" "serious" "sexy" "shady" "shaken" "shallow" "shattered" "sheepish" "shifty" "shiny"
                         "shocked" "shy" "sick" "silly" "sinful" "single" "sinister" "skeptical" "sketchy" "slaphappy"
                         "sleazy" "sleepless" "sleepy" "slinky" "slothful" "sluggish" "slutty" "sly" "smart" "smashing"
                         "smelly" "smiley" "smitten" "smooth" "smug" "snarky" "snazzy" "sneaky" "sneezy" "sniffly"
                         "so-so" "sober" "social" "somber" "sophisticated" "sore" "sorrowful" "sorry" "sour" "spacey"
                         "sparkly" "spastic" "spazzy" "special" "spectacular" "speechless" "spent" "spicy" "spiffy"
                         "spirited" "spiritual" "spiteful" "splendid" "split" "spoiled" "spontaneous" "spooky" "sporty"
                         "spunky" "squishy" "stabby" "stable" "starstruck" "starving" "stellar" "sticky" "stimulated"
                         "stoic" "stoked" "stoned" "stormy" "strange" "stressed" "strong" "stubborn" "stuck"
                         "studious" "stuffed" "stuffy" "stumped" "stunned" "stunning" "stupid" "stylish" "subdued"
                         "sublime" "submissive" "successful" "sullen" "sunny" "super" "superb" "superior" "supine"
                         "surly" "surprised" "surreal" "suspicious" "swamped" "swanky" "sweaty" "sweet" "swell"
                         "sympathetic" "taciturn" "talented" "talkative" "tearful" "tenacious" "tense" "terrible"
                         "terrified" "thankful" "thirsty" "thoughtful" "thrilled" "tickled" "tickled pink" "tipsy"
                         "tired" "tormented" "torn" "tortured" "touchy" "toxic" "tragic" "tranquil" "trapped"
                         "tricky" "trippy" "triumphant" "troubled" "twisted" "twitchy" "twitterpated" "ugh" "ugly"
                         "unappreciated" "unattractive" "uncertain" "uncomfortable" "undecided" "understimulated"
                         "undesirable" "uneasy" "unfulfilled" "ungrateful" "ungrounded" "unhappy" "unhealthy"
                         "unimportant" "uninspired" "unique" "unknown" "unloved" "unlucky" "unmedicated" "unmotivated"
                         "unpleasant" "unproductive" "unreal" "unsafe" "unsatisfied" "unsettled" "unstable"
                         "unsteady" "unstoppable" "unsure" "unwanted" "unworthy" "upbeat" "uplifted" "upset"
                         "upside-down" "used" "useful" "useless" "vacant" "vaccinated" "vain" "vamped" "vengeful"
                         "vexed" "vibrant" "vicious" "victorious" "vindictive" "violated" "violent" "virtuous"
                         "volatile" "vulnerable" "wacky" "wanted" "warm" "wasted" "weak" "weary" "weepy" "weird"
                         "well" "wet" "whatever" "whimsical" "whiney" "whiny" "wicked" "wild" "wired" "wise"
                         "wishful" "wistful" "witchy" "withdrawn" "witty" "wonderful" "woozy" "worldly" "worn"
                         "worried" "worthless" "wounded" "wretched" "wrong" "xenophilic" "young" "yucky" "yummy"
                         "zany" "zapped" "zealous" "zen" "zesty" "zoned" "zonked"))

;; No specific function for this I just eyeball https://xml.imood.org/faces.cgi
(defvar imood//faces '((0  "smiley"     "🙂") ;; id  .  internal name  .  emoji
                       (1  "frowny"     "🙁")
                       (2  "ragey"      "😡")
                       (3  "blah"       "🫥")
                       (4  "neutral"    "😶")
                       (5  "angelic"    "😇")
                       (6  "upsidedown" "🙃")
                       (7  "confused"   "😕")
                       (8  "embarassed" "😳")
                       (9  "magical"    "🪄")
                       (10 "sick"       "🤒")
                       (11 "evil"       "😈")
                       (12 "sleepy"     "🫩")
                       (13 "13"         "🇺🇸")
                       (14 "14"         "🥰")
                       (15 "15"         "🤥")
                       (16 "16"         "😏")
                       (17 "17"         "😵")
                       (18 "18"         "😸")
                       (19 "19"         "🫤")
                       (20 "20"         "♥️")
                       (21 "21"         "👁️")
                       (22 "22"         "😍")
                       (23 "23"         "🤫")
                       (24 "24"         "😢")
                       (25 "25"         "🧛‍♂️")
                       (26 "26"         "👽")
                       (27 "27"         "🥶")
                       (28 "28"         "🌈")
                       (29 "29"         "😋")
                       (30 "30"         "🤓")
                       (31 "31"         "👿")
                       (32 "32"         "🔰")))

(defun imood--list-to-params (params)
  "Converts a list of cons to url parameters"
  (let ((str "")
        (first t))
    (dotimes (i (length params))
      (when (nth i params)
        (if first
            (progn
              (setq str (concat str "?"))
              (setq first nil))
          (setq str (concat str "&")))
        (setq str (concat str (car (nth i params))))
        (setq str (concat str "="))
        (setq str (concat str (url-hexify-string (cadr (nth i params)))))))
    str))

(defun imood--get (base-url &optional params)
  "Returns request to a given `URL'"
  (let ((url base-url))
    (when params
        (setq url (concat url (imood--list-to-params params))))
  (with-current-buffer (url-retrieve-synchronously url t)
    (prog1
        (list url-http-response-status (buffer-substring-no-properties url-http-end-of-headers (point-max)))
      (kill-buffer)))))

(defun imood--html-to-xml-list (html)
  "Unwraps an HTML request to get the XML and convert it to a list."
  (with-temp-buffer
    (insert html)
    (nth 2 (nth 2 (libxml-parse-html-region (point-min) (point-max))))))

(defun imood//get-mood-list ()
  "Returns full list of moods"
  (let ((resp (imood--get "https://xml.imood.org/moods.cgi" ""))) ;; request
    (if (= (car resp) 200) ;; Error checking
        (let ((xml (imood--html-to-xml-list (cadr resp))))
          ;; Find all moods then put it into a list, also remove newline at the end
          (mapcar (lambda (mood) (replace-regexp-in-string "\n" "" (nth 3 mood))) (dom-by-tag xml 'mood)))
      (message (format "Request sent back %i" (car resp)))))) ;; If we don't get back 200 then tell user

(defun imood//get-current-mood (email)
  "Returns profile and mood of `EMAIL'"
  (let ((resp (imood--get "https://xml.imood.org/query.cgi" `(("email" ,email))))) ;; request
    (if (= (car resp) 200) ;; Error checking
        (let* ((xml (imood--html-to-xml-list (cadr resp)))
               (data (cdaddr xml)) ;; you laugh you go to hell
               (full-mood (cl-find 'mood data :key #'car))
               (mood    (nth 3 full-mood))
               (mood-fixed (replace-regexp-in-string "\n" "" mood))
               (face    (nth 2 (nth 5 full-mood)))
               (face-fixed (string-to-number face))
               (details (nth 2 (nth 4 full-mood))))
          (list `(mood    . ,mood-fixed)
                `(face    . ,face-fixed)
                `(details . ,details)))
      (message (format "Request sent back %i" (car resp))))))

(defun imood//get-own-current-mood ()
  "Get's own profile and mood"
  (imood//get-current-mood imood//email))

(defun imood//whats-my-mood ()
  (interactive)
  (let ((mood (imood//get-own-current-mood)))
    (print (assoc 'mood mood))
    (message (format "%s %s\n%s" (capitalize (cdr (assoc 'mood mood))) (nth 2 (nth (cdr (assoc 'face mood)) imood//faces)) (cdr (assoc 'details mood))))))

;; mood is a list of assoc ((mood . NUMBER) (face . NUMBER) (details . "STRING"))
(defun imood//change-mood (moodlst)
  "Changes the users mood"
  (let* ((mood (nth (cdr (assoc 'mood moodlst)) imood//moods))
         (face (number-to-string (nth 0 (nth (cdr (assoc 'face moodlst)) imood//faces))))
         (details (cdr (assoc 'details moodlst)))
         (resp (imood--get "https://xml.imood.org/update.cgi" `(("email" ,imood//email)
                                                                ("password" ,imood//password)
                                                                ("base" ,mood)
                                                                ("face" ,face)
                                                                ("personal" ,details))))) ;; request
    (if (= (car resp) 200) ;; Error checking
        (message "Mood updated!")
      (message (format "Request sent back %i" (car resp))))))

;;; imood.el ends here
