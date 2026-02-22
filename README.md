# Pixie's Filterlists

These are my personal filterlists — the ones I use across my router, VPN exclusions, uBlock Origin, and ublacklist.
They exist so I can set up a new device quickly without subscribing to dozens of individual lists by hand.

They’re not designed for general public use, but they’re public because I value transparency, reproducibility, and
having a canonical source of truth. If you want to use them, feel free — just know they’re curated for my own workflow
and preferences.

## Inspirations

These are the creators whose lists I use or admire.

- [BadBlock](https://codeberg.org/celenity/BadBlock)
- [DandelionSprout](https://github.com/DandelionSprout/adfilt)
- [DurableNapkin](https://github.com/durablenapkin/scamblocklist)
- [HaGeZi](https://github.com/hagezi/dns-blocklists)
- [kowith337](https://github.com/kowith337/PersonalFilterListCollection)
- [yokoffing](https://github.com/yokoffing/filterlists)

## Additional Interesting Lists

These are some of the additional lists that I use in my uBO setup, that aren't included in any metalists.

- [GDPR 451 List of Mostly American Websites Who Hate Europe and Privacy Rights](https://github.com/DandelionSprout/adfilt/blob/master/GDPR%20451%20List.txt)
- [uBlockOrigin & uBlacklist Huge AI Blocklist](https://github.com/laylavish/uBlockOrigin-HUGE-AI-Blocklist)
- [⛔ yokoffing's click2load filters](https://github.com/yokoffing/filterlists/blob/main/click2load.txt)

## Philosophy

My filtering ecosystem is built around:

- **Intentionality**: Every list has a purpose.
- **Layering**: Different tiers for different levels of strictness.
- **Inheritance**: Ensuring that my families devices inherit safe, stable layers.
- **Portability**: One canonical source for all my machines.
- **Respect**: All upstream lists are used unmodified and fully attributed.

## Why Metalists?

I use metalists because they give me:

- one subscription per tier
- consistent behavior across devices
- easy provisioning on new machines
- inherited protection for family
- a clean, intentional architecture

You can also see my [dotfiles](https://codeberg.org/pixiekat/dotfiles) and my [sublime text sync setup](https://codeberg.org/pixiekat/sublime-sync).

## List Tiers

A quick overview of how my lists are organized:

- Main Layer
- Pro Layer: Annoyance removal, cosmetic cleanup, UI fixes, and quality‑of‑life filters.
- Extreme Layer: Expressive, political, experimental, or intentionally aggressive filters.
- Mom & Dad Layer: Inherited, safe, stable, zero‑breakage filters curated specifically for non‑technical users.

## Upstream Lists by Tier

### Main Layer

- [BadBlock Amazon](https://badblock.celenity.dev/abp/amazon.txt)
- [BadBlock Annoyances](https://badblock.celenity.dev/abp/annoyances.txt)
- [BadBlock Apple](https://badblock.celenity.dev/abp/apple.txt)
- [BadBlock Brave](https://badblock.celenity.dev/abp/brave.txt)
- [BadBlock Crap](https://codeberg.org/celenity/BadBlock/raw/branch/pages/abp/crap.txt)
- [BadBlock Data Brokers](https://badblock.celenity.dev/abp/data-brokers.txt)
- [BadBlock DRM](https://badblock.celenity.dev/abp/drm.txt)
- [BadBlock Facebook](https://badblock.celenity.dev/abp/facebook.txt)
- [BadBlock Gaming](https://badblock.celenity.dev/abp/gaming.txt)
- [BadBlock Google](https://badblock.celenity.dev/abp/google.txt)
- [BadBlock Microsoft](https://badblock.celenity.dev/abp/microsoft.txt)
- [BadBlock Monitoring](https://badblock.celenity.dev/abp/monitoring.txt)
- [BadBlock Radar](https://badblock.celenity.dev/abp/radar.txt)
- [BadBlock Tiktok](https://badblock.celenity.dev/abp/tiktok.txt)
- [BadBlock Twitter](https://badblock.celenity.dev/abp/twitter.txt)
- [BadBlock Unsafe](https://badblock.celenity.dev/abp/unsafe.txt)
- [Clickbait Blocklist](https://raw.githubusercontent.com/cpeterso/clickbait-blocklist/master/clickbait-blocklist.txt)
- [NoCoin Filter List](https://raw.githubusercontent.com/hoshsadiq/adblock-nocoin-list/master/nocoin.txt)
- [🌞 Dandelion Sprout's Anti-Racism List](https://github.com/DandelionSprout/adfilt/raw/refs/heads/master/AntiRacismList.txt)
- [🎙 Rickroll Link Identifier](https://github.com/DandelionSprout/adfilt/raw/refs/heads/master/RickrollLinkIdentifier.txt)
- [🎛 Reddit Trash Removal Service](https://github.com/DandelionSprout/adfilt/raw/refs/heads/master/RedditTrashRemovalService.txt)
- [🎬 Stop Autoplay On Video Sites](https://github.com/DandelionSprout/adfilt/raw/refs/heads/master/StopAutoplayOnYouTube.txt)
- [🐐 Dandelion Sprout's Lightweight Anti-'Social share' List](https://github.com/DandelionSprout/adfilt/raw/refs/heads/master/SocialShareList.txt)
- [👨🏾🤵 Say No to Racism on Twitch](https://github.com/DandelionSprout/adfilt/raw/refs/heads/master/Sensitive%20lists/SayNoToRacismOnTwitch.txt)
- [🦨 Anti-Pepe List](https://github.com/DandelionSprout/adfilt/raw/refs/heads/master/AntiPepeList.txt)

## Attribution

All upstream lists are:

- Linked directly from their original maintainers.
- Unmodified (with the exception of removing local includes which don't work in the compiled megalists).
- Clearly credited.
- Not redistributed or repackaged.
- Included only as references inside my metalists.

This repo exists for personal convenience, not as a replacement for the original authors' work.
