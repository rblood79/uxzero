import React, { Component } from 'react';

const UserContext = React.createContext();

class UserProvider extends Component {
    // Context state
    state = {
        url: '/',
        filter: null,
        user: null,
        data: null,
    };
    // Method to update state
    setTheme = async theme => {
        this.setState(
            {
                theme: theme ? 'dark' : 'light',
            }
        );
    };
    
    setFilter = filter => {
        this.setState(prevState => ({ filter }));
    };
    setUser = user => {
        this.setState(prevState => ({ user }));
    };
    //
    render() {
        const { children } = this.props;
        const { url, theme, filter, user } = this.state;
        const { setTheme, setFilter, setUser } = this;

        return (
            <UserContext.Provider
                value={{
                    theme,
                    url,
                    filter,
                    user,
                    setTheme,
                    setFilter,
                    setUser,
                }}>
                {children}
            </UserContext.Provider>
        );
    }
}

export default UserContext;

export { UserProvider };
