![](https://files.catbox.moe/3r6dxn.png)

## Purpose

AniTag serves as a simple, lightweight local anime media manager with an emphasis on... well tagging. Video files can be accessed and played by your default video player. Unlike programs like Kodi, it is not meant to be a fully-featured media manager/ player.

## Primary Features

- Display and access local anime in one centralized location
- Integration with AniDB API
- Generate thumbnails for each library entry using FFMPEG
- A nice user interface that isn't built on Windows UI API
- And of course, tag and manage the tags of each library entry

## Some Pics!

![](https://files.catbox.moe/3eus1b.png)

![](https://files.catbox.moe/ihobwp.png)

## Under the Hood

AniTag is built on [Godot game engine](https://godotengine.org/). It's a rather unorthodox usage of Godot but hey, the results are pretty neat. Had to write a custom XML parser because Godot natively can't really deal with XML files. Also, turns out that Godot can pass commands to 7zip and ffmpeg. The more you know.

## Download

Grab the latest version here.

**Disclaimers:** While AniTag is mostly feature complete, the program is still in early stages of development. Expect crashes and random bugs. AniTag works best on a 1080p screen since its sole developer only has access to a 1080p monitor.

## Credits

- [u/willnationsdev](https://reddit.com/user/willnationsdev) for providing invaluable assistance throughout the six months of development. Helped me overcome several crucial stages in the development of AniTag.
- [u/whietfegeet](https://old.reddit.com/user/whietfegeet) AKA Fatorias AKA Apple for alpha testing and severing as impromptu QA.

## Quick Start Guide

1. Download AniTag
2. Run AniTag.exe
3. Create a library using this button
   1. ![](https://files.catbox.moe/e2ty9k.png)
4. Name the library and select the base directory. Make sure your anime is stored in a compatible file structure as shown in the Full Guide below.
5. Your new library will automatically build. Now, press the Bulk update shows button as shown here
   1. ![](https://files.catbox.moe/kvy0fv.png)
6. Some entries will still have the (!) symbol. Those entries will have to be manually added using the ![](https://files.catbox.moe/8mq5n3.png) icon on the far right. This button allows you to edit the metadata of the entry.
7.  From the metadata editing display, you can enter the AniDB name, hit 'Search Name' and get the AniDB ID of the show from the URL of the show. For example, 91 Days' AniDB page is found at https://anidb.net/anime/12014. Thus, 12014 is its AniDB ID. Input that ID into the AniDB ID section and hit 'Save Changes.'
   1. ![](https://files.catbox.moe/zaur9r.png)
8. Click the ![](https://files.catbox.moe/wj3ywn.png) button on the far right and the entry will be properly updated if the correct AniDB entry was inputted.
9. Optional: You can then hit the ![](https://files.catbox.moe/h10z8x.png)button on the top left to generate thumbnails for the entire library. Warning- this will take a while!

## Full Guide

### Library file structure

- Make sure your anime is stored in a compatible file structure. For example:
- MyLibrary
  - 91 Days
    - Episode 1.mkv
    - Episode 2.mkv
  - Fate/ Zero
    - Episode 1.mkv
- For best results, make sure the folder holding the anime are named like they are on AniDB

### AniTag UI

#### Left Display

- The top left bar has several buttons. Each button has a tooltip which states the button's purpose.

  ![](https://files.catbox.moe/q3m870.png)

  - Load a library- load an existing library
  - Build a library- build a new library. You can input a name for the library and select the base directory. Make sure your files are stored in a compatible file structure as described above.
  - Rescan current library- use this if you add new entries into the main library folder-- or if you delete files from the library folder.
  - Randomize- don't know what to watch? This button will direct you to a random entry in your library.
  - Bulk generate thumbnails- generates thumbnails for all entries in your library with an AniDB ID assigned. This will take a while!
  - Bulk update shows- grabs information from AniDB for each entry in your library. Avoid updating too many shows at once or AniDB might API ban you.

- Below that we have the search bar and the tag filter button. The tag filter button allows you to display anime that have your selected tags. Click on a currently filtered tag to remove it from the filter.

- And below all that is the list of shows in your library. Some have an (!) mark. Those are shows that do not have an AniDB ID assigned yet. More on that later.

#### Center

![](https://files.catbox.moe/r2nrjm.png)

- Displays some basic information of the anime.
- Specific tags can be hidden by right clicking on them. This will globally hide the tag, aka hide the tag for all shows. Hiding tags for specific shows will be coming soon tm.
- The last tag will always be a '+' button. If you want to add a new tag to that show, click on that button.
- All relevant video files for the show in the folder are listed below the tags.

#### Right bar

![](https://files.catbox.moe/5peo4o.png)

- The right bar is for managing the selected Anime entry.
- Open directory- opens the folder of the entry
- Open database directory- opens the folder which contains the AniDB entry on this entry
- Update metadata from AniDB- downloads the metadata from AniDB. Will search based on your folder name. Must be an exact match
- Open AniDB page- opens the entry's AniDB profile page
- Generate thumbnails- generates thumbails from the first episode for this entry
- Edit metadata- allows you to edit entry information such as name and description. **You can also assign an AniDB ID here if AniTag fails to assign one during scanning.** Use the "Search Name" button. The ID will be the bunch of numbers at the URL of the anime's page. eg https://anidb.net/anime/11577 -> AniDB ID is 11577.
- Delete library entry- deletes the entry from this library permanently. Does not affect any actual files.