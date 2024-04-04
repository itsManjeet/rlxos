const updateClock = () => {
  const time = new Date();
  let hour = time.getHours();
  const min = time.getMinutes();
  let am_pm = "AM";
  if (hour >= 12) {
    if (hour > 12) hour -= 12;
    am_pm = "PM";
  }

  let currentTime = hour + ":" + min + " " + am_pm;
  const allClocks = document.getElementsByClassName('clock-interval');
  for (let i = 0; i < allClocks.length; i++) {
    allClocks[i].innerHTML = currentTime;
  }
};

setInterval(updateClock, 1000);
updateClock();