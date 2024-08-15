
import React, { useContext, useState, useEffect } from 'react';
import { useHistory } from "react-router-dom";
import { doc, getDoc } from 'firebase/firestore';
import context from '../component/Context';
import mnd from '../assets/logo.svg';

const App = (props) => {
  //const [number, setNumber] = useState("");
  //const [pw, setPw] = useState("");

  const state = useContext(context);
  const { setUser, setYear } = state;
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
        setYear(docSnap.data().year);

        // localStorage에 사용자 정보 저장
        localStorage.setItem('user', number);
        localStorage.setItem("year", JSON.stringify(docSnap.data().year));

        history.push('/');
      } else {
        setInputs({
          number: '', pw: ''
        })
      }
    } else {
      //setNumber('접속이 원활하지 않습니다')
    }
  }

  useEffect(() => {
    // localStorage에서 사용자 정보 불러오기
    const storedUser = localStorage.getItem('user');
    const storedYear = JSON.parse(localStorage.getItem('year'));

    if (storedUser && storedYear) {
      setUser(storedUser);
      setYear(storedYear);
    } else {
      setUser(null);
      setYear(null);
    }
  }, [setUser, setYear]);

  const [inputs, setInputs] = useState({
    number: "",
    pw: "",
  });
  const { number, pw } = inputs;
  //const [regColor, setColor] = useState('all');

  const onChange = (e) => {
    const { name, value } = e.target;
    setInputs({
      ...inputs,
      [name]: value || "",
    });
  };

  return (
    <div className='container'>
      <div className='login'>
        <div className='visual'>
          <div className='visualText'>
            <div className='textGroup'>
              <span>과</span><span>제</span><span>관</span><span>리</span>
              <span>대</span><span>장</span>
            </div>
            <img className='visualLogo' src={mnd} alt={'logo'} />
          </div>
        </div>
        <div>
          <form onSubmit={(e) => { e.preventDefault() }}>
            <div className='armyWrap'>
              <div className={'input'}>
                
                <input
                  className={'id'}
                  type="text"
                  id='number'
                  name="number"
                  maxLength={12}
                  placeholder="아이디"
                  onChange={onChange}
                  value={number || ""}
                />
              </div>
              <div className={'input'}>
                
                <input
                  className={'pw'}
                  type={view ? 'text' : 'password'}
                  id='pw'
                  name="pw"
                  maxLength={12}
                  placeholder="비밀번호"
                  onChange={onChange}
                  autoComplete="off"
                  value={pw || ""}
                />
                <button className='passView' onClick={() => { setView(view ? false : true) }} title="pass view"><i className={view ? "ri-eye-off-line" : "ri-eye-line"}></i></button>
                <span className={'vali'}>{number === "" && pw === "" ? '아이디와 비밀번호는 관리자에게 문의하세요' : number === 'fail' ? '올바른 아이디가 아닙니다' : pw === 'fail' ? '비밀번호를 입력하세요' : pw === 'same' && '비밀번호가 일치하지 않습니다'}</span>
              </div>
            </div>
            <div className='controll'>
              <button className={'button sign'} onClick={() => {
                onCheck(number)
              }}>확인</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}

App.defaultProps = {};

export default App;