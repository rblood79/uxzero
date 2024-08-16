
import React, { useContext } from 'react';
import { NavLink, useHistory } from "react-router-dom";
import context from './Context';
import { isMobile } from 'react-device-detect';
import logo from '../assets/logo.svg';
const App = (props) => {
  const state = useContext(context);
  const history = useHistory();
  const { user, setUser, setYear } = state;
  const logOut = () => {
    setUser(null);
    setYear(null);
    // localStorage에서 사용자 정보 삭제
    localStorage.removeItem('user');
    localStorage.removeItem('year');

    history.replace('/');
  }

  /*useEffect(() => {
    const storedUser = localStorage.getItem('user');
    if (!storedUser) {
      history.replace('/');
    } else {
      history.push('/');
    }
  }, [history, setUser, setYear]);*/

  return (
    <header className="head">
      <nav className='nav sub'>
        <div className='headGroup'>
          <div className='headTitle'><img src={logo} alt='MND' /><span>과제관리대장</span></div>
          {isMobile && <button className='logout' onClick={logOut} title="로그아웃"><i className="ri-logout-box-r-line"></i></button>}
        </div>
        <div className='navRes'>
          <NavLink className='navButton' exact to="/" title="과제목록"><i className="ri-todo-line"></i><span>관리목록</span></NavLink>
          <NavLink className='navButton' exact to="/write" title="과제등록"><i className="ri-pencil-line"></i><span>과제등록</span></NavLink>
        </div>
        {!isMobile && <div className='headRight'><button className='logout' onClick={logOut} title="로그아웃"><span>{user && user}</span><i className="ri-logout-box-r-line"></i></button></div>}
      </nav>
    </header>
  );
}
export default App;