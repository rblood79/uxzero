
import React, { useContext } from 'react';
import { NavLink } from "react-router-dom";
import context from './Context';
import { isMobile } from 'react-device-detect';
import logo from '../assets/logo.svg';
const App = (props) => {
  const state = useContext(context);
  //const history = useHistory();
  const { user, setUser } = state;
  const test = () => {
    //alert('시험버전에선 제공되지 않습니다')
    setUser(null);
  }

  return (
    <header className="head">
      <nav className='nav sub'>
        <div className='headTitle'><img src={logo} alt='MND'/><span>과제관리프로그램</span></div>
        <div className='navRes'>
          <NavLink className='navButton' exact to="/result"><i className="ri-todo-line"></i>과제목록</NavLink>
          <NavLink className='navButton' exact to="/form"><i className="ri-pencil-line"></i>과제등록</NavLink>
        </div>
        {!isMobile && <div className='headRight'><button className='logout' onClick={test} title="로그아웃"><span>{user && user}</span><i className="ri-logout-box-r-line"></i></button></div>}
      </nav>
    </header>
  );
}
export default App;