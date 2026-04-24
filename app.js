let map = L.map('map').setView([56.9496, 24.1052], 13);

L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
  maxZoom: 19,
  attribution: '© OpenStreetMap'
}).addTo(map);

let watchId = null;
let points = [];
let distance = 0;
let polyline = L.polyline([], { color: '#00ff99', weight: 5 }).addTo(map);
let openedLayer = L.layerGroup().addTo(map);

const startBtn = document.getElementById('startBtn');
const stopBtn = document.getElementById('stopBtn');
const statusEl = document.getElementById('status');
const distanceEl = document.getElementById('distance');

function toRad(value) {
  return value * Math.PI / 180;
}

function distanceMeters(a, b) {
  const R = 6371000;
  const dLat = toRad(b.lat - a.lat);
  const dLng = toRad(b.lng - a.lng);
  const lat1 = toRad(a.lat);
  const lat2 = toRad(b.lat);

  const x =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.sin(dLng / 2) * Math.sin(dLng / 2) *
    Math.cos(lat1) * Math.cos(lat2);

  return R * 2 * Math.atan2(Math.sqrt(x), Math.sqrt(1 - x));
}

function saveTrack() {
  localStorage.setItem('black_world_map_points', JSON.stringify(points));
  localStorage.setItem('black_world_map_distance', String(distance));
}

function loadTrack() {
  const saved = localStorage.getItem('black_world_map_points');
  const savedDistance = localStorage.getItem('black_world_map_distance');

  if (saved) {
    points = JSON.parse(saved);
    polyline.setLatLngs(points);
    points.forEach(p => {
      L.circle(p, {
        radius: 80,
        color: '#ffffff',
        fillColor: '#ffffff',
        fillOpacity: 0.22,
        weight: 1
      }).addTo(openedLayer);
    });

    if (points.length > 0) {
      map.setView(points[points.length - 1], 15);
    }
  }

  if (savedDistance) {
    distance = Number(savedDistance);
    distanceEl.textContent = (distance / 1000).toFixed(2) + ' km';
  }
}

function onPosition(pos) {
  const point = {
    lat: pos.coords.latitude,
    lng: pos.coords.longitude
  };

  if (points.length > 0) {
    const last = points[points.length - 1];
    const d = distanceMeters(last, point);

    if (d < 5 || d > 1000) return;

    distance += d;
  }

  points.push(point);
  polyline.addLatLng(point);

  L.circle(point, {
    radius: 80,
    color: '#ffffff',
    fillColor: '#ffffff',
    fillOpacity: 0.22,
    weight: 1
  }).addTo(openedLayer);

  map.setView(point, 16);
  distanceEl.textContent = (distance / 1000).toFixed(2) + ' km';
  statusEl.textContent = 'Tracking...';

  saveTrack();
}

function onError(error) {
  statusEl.textContent = 'GPS error: ' + error.message;
}

startBtn.onclick = () => {
  if (!navigator.geolocation) {
    statusEl.textContent = 'GPS not supported';
    return;
  }

  watchId = navigator.geolocation.watchPosition(
    onPosition,
    onError,
    {
      enableHighAccuracy: true,
      maximumAge: 0,
      timeout: 15000
    }
  );

  startBtn.disabled = true;
  stopBtn.disabled = false;
  statusEl.textContent = 'Waiting for GPS...';
};

stopBtn.onclick = () => {
  if (watchId !== null) {
    navigator.geolocation.clearWatch(watchId);
    watchId = null;
  }

  startBtn.disabled = false;
  stopBtn.disabled = true;
  statusEl.textContent = 'Stopped';
};

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('sw.js');
}

loadTrack();
