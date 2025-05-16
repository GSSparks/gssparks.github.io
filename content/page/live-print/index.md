---
title: "Live 3D Print"
aliases:
  - live-print
ReadingTime: false
menu:
    main:
        weight: -90
draft: true
---
{{< rawhtml >}}
<script>
  async function checkStream() {
    const img = document.getElementById("printer-stream");
    try {
      const response = await fetch("http://192.168.1.111:8080/?action=snapshot", { mode: 'no-cors' });
      if (response.ok || response.status === 0) {
        img.style.display = "block";
      } else {
        img.style.display = "none";
      }
    } catch (error) {
      img.style.display = "none";
    }
  }
  window.onload = checkStream;
</script>

<img id="printer-stream" src="http://192.168.1.111:8080/?action=stream" style="display:none;" alt="3D Printer Live Stream">
{{< /rawhtml >}}
