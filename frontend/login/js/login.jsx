import React from 'react';
import 'whatwg-fetch';

export default class Login extends React.Component {
    constructor(props) {
        super(props);

        this.state = {
            login: '',
            password: ''
        };
    }

    render() {
        return (
            <div className="container">
                <form className="form-signin" onSubmit={this.onSubmit}>
                    <h2 className="form-signin-heading">Please sign in</h2>

                    <div className="input-row">
                        <label htmlFor="inputEmail" className="sr-only">Email address</label>
                        <input type="text" id="inputEmail" name="login" className="form-control" placeholder="Login"
                               required autoFocus={true} value={this.state.login} onChange={this.onChange}/>
                    </div>
                    <div className="input-row">
                        <label htmlFor="inputPassword" className="sr-only">Password</label>
                        <input type="password" id="inputPassword" name="password" className="form-control"
                               placeholder="Password" required value={this.state.password} onChange={this.onChange}/>
                    </div>

                    <button className="btn btn-lg btn-primary btn-block" type="submit" onClick={this.onSubmit}>
                        Sign in
                    </button>
                </form>
            </div>
        );
    }

    onChange = (e) => {
        let target = e.target;

        this.setState({
            [target.name]: target.value
        });
    };

    onSubmit = (e) => {
        e.preventDefault();

        fetch('/login', {
            method: 'POST',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(this.state)
        }).then((response) => {
            return response.json();
        }).then((json) => {
            if (json.code === 'ERROR') {
                alert(json.message);
            } else {
                window.location = json.redirect_to;
            }
        });
    };
}
