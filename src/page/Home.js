
import React, { useContext, useState, useEffect } from 'react';
import { useHistory } from "react-router-dom";
import { doc, getDoc } from 'firebase/firestore';
import context from '../component/Context';
import mnd from '../assets/logo.svg';

const App = (props) => {
  const [number, setNumber] = useState(null);
  const [pw, setPw] = useState(null);

  const state = useContext(context);
  const { setUser } = state;
  const [view, setView] = useState(false);
  const history = useHistory();

  //let reg_num = /^[0-9]{6,10}$/; // 전화번호 숫자만
  //let regex = /[^0-9]/g;

  const onCheck = async () => {
    const docRef = doc(props.manage, "ini");
    const docSnap = await getDoc(docRef);
    if (docSnap.exists()) {
      if (number === docSnap.data().adminID && pw === docSnap.data().adminPW) {
        setUser(number);
        history.push('/result')
      } else {
        setNumber(null)
        setPw(null)
      }
    } else {
      //setNumber('접속이 원활하지 않습니다')
    }


  }

  useEffect(() => {
    //console.log(props)
    setNumber(null)
    setPw(null)
    //setArmy(null)
    setUser(null)
  }, [setUser])

  return (
    <div className='container'>
      <div className='login'>
        <div className='visual'>
          <div className='visualText'>
            <div className='textGroup'>
              <span>과</span><span>제</span><span>관</span><span>리</span>
              <span>프</span><span>로</span><span>그</span><span>램</span>
            </div>
            <img className='visualLogo' src={mnd} alt={'logo'} />
          </div>
        </div>
        <div>
          <div className='armyWrap'>
            <form>
              <div className={'input'}>
                <input className={'id'} type='text' maxLength={12} placeholder="아이디" onChange={({ target: { value } }) => {
                  setNumber(value)
                }} />
              </div>
              <div className={'input'}>
                <input className={'pw'} type={view ? 'text' : 'password'} maxLength={12} placeholder="비밀번호" autoComplete="off" onChange={({ target: { value } }) => {
                  setPw(value)
                }} />
                <button className='passView' onClick={() => { setView(view ? false : true) }}><i className={view ? "ri-eye-off-line" : "ri-eye-line"}></i></button>
                <span className={'vali'}>{number === null && pw === null ? '아이디와 비밀번호는 관리자에게 문의하세요' : number === 'fail' ? '올바른 아이디가 아닙니다' : pw === 'fail' ? '비밀번호를 입력하세요' : pw === 'same' && '비밀번호가 일치하지 않습니다'}</span>
              </div>
            </form>
          </div>
          <div className='controll'>

            <button className={'button'} onClick={() => {
              onCheck(number)
            }}>확인</button>

          </div>
        </div>
      </div>
    </div>
  );
}

App.defaultProps = {
};

export default App;