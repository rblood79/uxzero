
import React, { useContext } from 'react';
import { NavLink } from "react-router-dom";
import context from './Context';
import { isMobile } from 'react-device-detect';
import logo from '../assets/logo.svg';
const App = (props) => {
  const state = useContext(context);
  //const history = useHistory();
  const { user, setUser } = state;
  const logOut = () => {
    setUser(null);
  }

  return (
    <header className="head">
      <nav className='nav sub'>
        <div className='headTitle'><img src={logo} alt='MND'/><span>과제관리대장</span></div>
        <div className='navRes'>
          <NavLink className='navButton' exact to="/result" title="과제목록"><i className="ri-todo-line"></i><span>관리목록</span></NavLink>
          <NavLink className='navButton' exact to="/form" title="과제등록"><i className="ri-pencil-line"></i><span>과제등록</span></NavLink>
        </div>
        {!isMobile && <div className='headRight'><button className='logout' onClick={logOut} title="로그아웃"><span>{user && user}</span><i className="ri-logout-box-r-line"></i></button></div>}
      </nav>
    </header>
  );
}
export default App;