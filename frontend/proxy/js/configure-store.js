import { createStore, applyMiddleware } from 'redux';
import thunkMiddleware from 'redux-thunk';
import { createLogger } from 'redux-logger';
import rootReducer from 'proxy/js/reducers';

const loggerMiddleware = createLogger();

export default function configureStore(preLoadedState) {
    return createStore(
        rootReducer,
        preLoadedState,
        applyMiddleware(
            thunkMiddleware,
            loggerMiddleware
        )
    );
}
