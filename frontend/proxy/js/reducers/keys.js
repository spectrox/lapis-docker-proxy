import { RECEIVE_LISTS, REQUEST_LISTS } from 'proxy/js/actions';

const keys = (state = {items: {}, isFetching: false}, action) => {
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

export default keys;
