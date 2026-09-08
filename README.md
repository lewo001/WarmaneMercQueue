# WarmaneMercQueue (WMQ)

A lightweight World of Warcraft (WotLK 3.3.5a) AddOn built specifically for Warmane. It displays real-time Battleground and Arena queue timers with multi-queue support and dynamic Mercenary Mode status detection.

---

## Features

* **Live Queue Tracking:** Displays active elapsed wait times for specific Battlegrounds and Arena brackets (2v2, 3v3, 5v5).
* **Multi-Queue Support:** Automatically stacks active queues into separate, clean lines if you are queued for multiple BGs simultaneously.
* **Mercenary Mode Detection:** Reads Warmane's server-side toggle (`MERCENARYMODE_ENABLED`) and appends **`(Mercenary ON)`** in bright red text when active.
* **Fully Customizable:** Easily adjust frame positioning, text scaling, and transparency to fit your UI.
* **Persistent Settings:** SavedVariables (`WarmaneMercQueueDB`) ensure frame placement, scale, opacity, and lock status persist across reloads and relogs.

Access settings using `/wmq` or `/mercqueue`:

```
/wmq lock          Locks the frame position
/wmq unlock        Unlocks the frame to drag and reposition
/wmq scale <val>   Adjusts size (e.g., /wmq scale 120 or 1.2)
/wmq alpha <val>   Adjusts transparency (e.g., /wmq alpha 75 or 0.75)
/wmq reset        Resets position, scale, and opacity to default
````
Download the latest version [here](https://github.com/lewo001/WarmaneMercQueue/releases/download/wmq-1.0/WarmaneMercQue.rar).

