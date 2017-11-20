import { RECEIVE_LISTS, REQUEST_LISTS } from 'proxy/js/actions';

const ports = (state = {items: {}, isFetching: true}, action) => {
    switch (action.type) {
        case RECEIVE_LISTS:
            return {
                items: {...state.items},
                isFetching: false
            };
        case REQUEST_LISTS:
            return {
                items: {},
                isFetching: true
            };
        default:
            return state;
    }
};

export default ports;
