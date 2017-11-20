import 'whatwg-fetch';

export const REQUEST_LISTS = 'REQUEST_LISTS';
export const RECEIVE_LISTS = 'RECEIVE_LISTS';

function requestLists() {
    return {
        type: REQUEST_LISTS,
        hosts: {},
        ports: {},
        keys: {}
    };
}

function receiveLists(json = {}) {
    return {
        type: RECEIVE_LISTS,
        hosts: json.hosts || {},
        ports: json.ports || {},
        keys: json.keys || {}
    };
}

export function fetchLists() {
    return dispatch => {
        dispatch(requestLists());

        return fetch('/api/list', {
            credentials: 'same-origin'
        })
            .then(response => response.json())
            .then(json => {
                if (json.code && json.code === 'REDIRECT_AUTH') {
                    window.location = '/login';

                    return false;
                }
            })
            .then(json => dispatch(receiveLists(json)));
    };
}
