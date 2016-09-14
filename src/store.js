const initialState = {
  fontFamilies: [],
  observer: null,
  queue: [],
  processed: [],
}

function reducer(state, [type, payload]) {
  switch (type) {
    case 'elm_fontsLoaded':
      return Object.assign({}, initialState, {
        fontFamilies: payload,
      });

    case 'observersSet':
      return Object.assign({}, state, {
        observer: payload,
      });

    case 'itemsProcessed':
      return Object.assign({}, state, {
        queue: [],
        processed: state.processed.concat(payload),
      });

    case 'itemsVisible':
      return Object.assign({}, state, {
        queue: payload.reduce((prev, curr) => {
          if (prev.includes(curr) || state.processed.includes(curr)) return prev;
          return prev.concat([curr]);
        }, state.queue),
      });

    default:
      return state;
  }
}


export default ((reducer, initialState) => {
  const subscribers = [];

  let state = initialState;

  const dispatch = action => {
    state = reducer(state, action);
    subscribers.forEach(fn => fn(action, state));
  }

  const subscribe = subscribers.push.bind(subscribers);
  const getState = () => state;

  return {
    dispatch,
    subscribe,
    getState,
  };
})(reducer, initialState);
