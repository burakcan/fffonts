import 'normalize.css';
import './Main/style.css';
import './FontList/style.css';
import './FontDetail/style.css';

import store from './store.js';
import { Main } from './Main.elm';
import webFontLoader from 'webfontloader';

const persistedBuckets = localStorage.getItem('fffonts_buckets');

const app = Main.fullscreen({
  'apiBase':
    'https://www.googleapis.com/webfonts/v1/webfonts?key=AIzaSyAiSMio183otg9gHQPxr8-2_ECvjGXu8l8',
  'buckets':
    persistedBuckets ? JSON.parse(persistedBuckets) : [["Favorites",[]]],
});

app.ports.stringListPort.subscribe(store.dispatch);
app.ports.booleanPort.subscribe(store.dispatch);
app.ports.persistBuckets.subscribe(store.dispatch);

store.subscribe(([type, payload], state) => {
  switch (type) {
    case 'elm_fontsLoaded':
      return requestIdleCallback(() => setObservers(payload));

    case 'elm_loadFontWithVariants':
      return loadFontWithVariants(payload);

    case 'elm_search':
      return requestIdleCallback(() => setObservers(payload));

    case 'elm_persistBuckets':
      return requestIdleCallback(() => persistBuckets(payload));

    case 'itemsVisible':
      return requestIdleCallback(() => loadFontStyles(state));

    default:
      return false;
  }
});

function persistBuckets(buckets) {
  localStorage.setItem('fffonts_buckets', JSON.stringify(buckets));
}

function itemStatus(status) {
  return function(name) {
    app.ports.itemStatusPort.send([name, status]);
  }
}

function loadFontWithVariants([family, ...variants]) {
  store.dispatch(['itemsProcessed', [family]]);

  itemStatus('loading')(family);

  webFontLoader.load({
    'google': {
      'families': [`${family}:${variants.join(",")}`],
    },
    'fontloading': itemStatus('loading'),
    'fontactive': itemStatus('active'),
    'fontinactive': itemStatus('failed'),
    'classes': false,
  });
}

function loadFontStyles({ queue, processed }) {
  if (queue.length === 0) return false;

  store.dispatch(['itemsProcessed', queue]);

  webFontLoader.load({
    'google': {
      'families': queue,
    },
    'fontloading': itemStatus('loading'),
    'fontactive': itemStatus('active'),
    'fontinactive': itemStatus('failed'),
    'classes': false,
  });
}

function setObservers(fontFamilies) {
  const allItems = Array.from(document.getElementsByClassName('FontListItem'));
  const container = document.getElementsByClassName('Content')[0];

  store.dispatch([
    'itemsVisible',
    fontFamilies.slice(0, 10)
  ]);

  const observer = new IntersectionObserver(
    entries =>
      store.dispatch([
        'itemsVisible',
        entries.map(
          entry => entry.target.getAttribute('data-family')
        )
    ])
    , { root: container }
  );

  allItems
  .forEach(
    item => observer.observe(item)
  );

  store.dispatch(['observersSet', observer]);
}
