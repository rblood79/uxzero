import _ from 'lodash';
import React, { useContext, useState, useEffect, useMemo } from 'react';
import { useHistory, useLocation } from "react-router-dom";
import { doc, deleteDoc, getDoc, setDoc, updateDoc } from 'firebase/firestore';
import moment from "moment";
import 'moment/locale/ko';
import context from '../component/Context';

const App = (props) => {
  const history = useHistory();
  const state = useContext(context);
  const location = useLocation();
  const { user } = state;
  const [data, setData] = useState(null);
  const [startcompyear, setStartcompyear] = useState(null);
  const [startcompresult, setStartcompresult] = useState(null);
  const [endcompresult, setEndcompresult] = useState(null);
  const [startyear, setStartyear] = useState(null);
  const [startresult, setStartresult] = useState(null);
  const [endresult, setEndresult] = useState(null);
  const [color, setColor] = useState(null);

  const memoizedInputs = useMemo(() => ({
    id: data?.ID || "",
    checknum: data?.CHECKNUM || "",
    leader: data?.LEADER || "",
    title: data?.TITLE || "",
    endcompyear: data?.ENDCOMPYEAR || "",
    endyear: data?.ENDYEAR || "",
    result: data?.RESULT || "",
    indi: data?.INDI || "",
    unit: data?.UNIT || "",
    datay0: data?.DATAY0 || "",
    datay1: data?.DATAY1 || "",
    datay2: data?.DATAY2 || "",
    datay3: data?.DATAY3 || "",
    datay4: data?.DATAY4 || "",
    datay5: data?.DATAY5 || "",

  }), [data]);

  const [inputs, setInputs] = useState(memoizedInputs);
  const { id, checknum, leader, title, endcompyear, endyear, result, indi, unit, datay0, datay1, datay2, datay3, datay4, datay5 } = inputs;

  const onChange = (e) => {
    const { name, value } = e.target;
    setInputs({
      ...inputs,
      [name]: value || "",
    });
  };

  const startCompResultArray = ["완료", "조건부완료", "중단", "연장"];
  const endCompResultArray = ["완료", "조건부완료", "중단", "연장", "1차완료"];
  const startResultArray = ["인증", "인증(대상)", "인증(금상)", "인증(은상)", "인증(동상)", "인증(장려)", "미인증(중단)", "미인증(재도전)"];
  const endResultArray = ["인증", "인증(대상)", "인증(금상)", "인증(은상)", "인증(동상)", "인증(장려)", "미인증(중단)"];
  const yearArray = ["2014", "2015", "2016", "2017", "2018", "2019", "2020", "2021", "2022", "2023", "2024", "2025", "2026", "2027", "2028", "2029", "2030", "2031", "2032", "2033", "2034"];
  const colorArray = ["red", "green", "yellow"];

  const onLoad = async () => {
    if (location.state) {
      const docRef = doc(props.manage, location.state.userCell);
      const docSnap = await getDoc(docRef);
      if (docSnap.exists()) {
        setData(docSnap.data());
      } else {
        console.log("No such document!");
      }
    }
  };

  const onSucsses = async (id) => {
    if (location.state) {
      const docRef = doc(props.manage, location.state.userCell);
      const docSnap = await getDoc(docRef);
      if (docSnap.exists()) {
        //console.log(data,'//' ,docSnap.data())
        !_.isEqual(data, docSnap.data()) && history.push('/result', { updated: true });
      } else {
        console.log('fail');
      }
    } else {
      history.push('/result', { updated: true });
    }
  };

  const deleteCheck = async (id) => {
    const docRef = doc(props.manage, id);
    const docSnap = await getDoc(docRef);
    if (docSnap.exists()) {
      console.log('아직있음');
    } else {
      history.push('/result', { updated: true });
    }
  };

  useEffect(() => {
    if (data) {
      setInputs(memoizedInputs);
      setStartcompyear(data.STARTCOMPYEAR);
      setStartcompresult(data.STARTCOMPRESULT);
      setEndcompresult(data.ENDCOMPRESULT);
      setStartyear(data.STARTYEAR);
      setStartresult(data.STARTRESULT);
      setEndresult(data.ENDRESULT);
      setColor(data.COLOR);
    }
  }, [data, memoizedInputs]);

  useEffect(() => {
    !user ? history.push('/') : onLoad();
  }, []);

  const onDelete = async () => {
    if (location.state) {
      await deleteDoc(doc(props.manage, location.state.userCell), deleteCheck(location.state.userCell));
    }
  };

  const onBack = ()=>{
    history.push('/result', { updated: false });
  }

  const onSave = async () => {
    const docRef = doc(props.manage, id);
    const docSnap = await getDoc(docRef);
    if (docSnap.exists()) {
      alert("관리번호 " + id + "가 등록 되어있습니다 기존자료에서 수정하거나 관리번호를 변경하여 등록 하세요");
    } else {
      await setDoc(doc(props.manage, id), {
        ID: id,
        CHECKNUM: checknum,
        LEADER: leader,
        TITLE: title,
        STARTCOMPYEAR: startcompyear,
        STARTCOMPRESULT: startcompresult,
        ENDCOMPYEAR: endcompyear,
        ENDCOMPRESULT: endcompresult,
        STARTYEAR: startyear,
        STARTRESULT: startresult,
        ENDYEAR: endyear,
        ENDRESULT: endresult,
        RESULT: result,
        COLOR: color,
        INDI: indi,
        UNIT: unit,
        DATAY0: datay0,
        DATAY1: datay1,
        DATAY2: datay2,
        DATAY3: datay3,
        DATAY4: datay4,
        DATAY5: datay5,
        DATE: new Date().toUTCString()
      }, onSucsses(id));
    }
  };

  const onUpdate = async () => {
    await updateDoc(doc(props.manage, id), {
    //await setDoc(doc(props.manage, id), {
      ID: id,
      CHECKNUM: checknum,
      LEADER: leader,
      TITLE: title,
      STARTCOMPYEAR: startcompyear,
      STARTCOMPRESULT: startcompresult,
      ENDCOMPYEAR: endcompyear,
      ENDCOMPRESULT: endcompresult,
      STARTYEAR: startyear,
      STARTRESULT: startresult,
      ENDYEAR: endyear,
      ENDRESULT: endresult,
      RESULT: result,
      COLOR: color,
      INDI: indi,
      UNIT: unit,
      DATAY0: datay0,
      DATAY1: datay1,
      DATAY2: datay2,
      DATAY3: datay3,
      DATAY4: datay4,
      DATAY5: datay5,
      DATE: new Date().toUTCString()
    }, onSucsses(id));
  };

  return (
    <>
      <div className='order'>
        <div className='users'>
          <div className='resultHead'>
            <h2 className='title'>과제{data ? '수정' : '등록'}</h2>
            <span>{data && "마지막 수정일 " + moment(data.DATE).format("YYYY-MM-DD hh:mm:ss")}</span>
          </div>
          <div className='formBody'>
            <h3>단일입력</h3>
            <div className='formGroup'>
              <div className='formWrap'>
                <label className='label'>관리번호</label>
                <input
                  name="id"
                  placeholder="입력하세요(등록후 변경 불가합니다)"
                  onChange={onChange}
                  value={id || ""}
                  disabled={data}
                />
              </div>
              <div className='formWrap'>
                <label className='label'>확인번호</label>
                <input
                  name="checknum"
                  placeholder="입력하세요"
                  onChange={onChange}
                  value={checknum || ""}
                />
              </div>
              <div className='formWrap'>
                <label className='label'>팀장</label>
                <input
                  name="leader"
                  placeholder="입력하세요"
                  onChange={onChange}
                  value={leader || ""}
                />
              </div>
              <div className='formWrap'>
                <label className='label'>과제명</label>
                <input
                  name="title"
                  placeholder="입력하세요"
                  onChange={onChange}
                  value={title || ""}
                />
              </div>
              <div className='formWrap borderTop'>
                <label className='label'>1차 완료평가연도</label>
                <select onChange={(e) => { setStartcompyear(e.target.value) }} value={startcompyear ? startcompyear : "default"}>
                  <option value="default" disabled>선택하세요</option>
                  {yearArray.map((item) => (
                    <option value={item} key={item}>
                      {item}
                    </option>
                  ))}
                </select>
              </div>
              <div className='formWrap borderTop'>
                <label className='label'>1차 완료평가결과</label>
                <select onChange={(e) => { setStartcompresult(e.target.value) }} value={startcompresult ? startcompresult : "default"}>
                  <option value="default" disabled>선택하세요</option>
                  {startCompResultArray.map((item) => (
                    <option value={item} key={item}>
                      {item}
                    </option>
                  ))}
                </select>
              </div>
              <div className='formWrap borderTop'>
                <label className='label'>2차 완료평가연도</label>
                <input
                  name="endcompyear"
                  placeholder="입력하세요"
                  onChange={onChange}
                  value={endcompyear || ""}
                />
              </div>
              <div className='formWrap borderTop'>
                <label className='label'>2차 완료평가결과</label>
                <select onChange={(e) => { setEndcompresult(e.target.value) }} value={endcompresult ? endcompresult : "default"}>
                  <option value="default" disabled>선택하세요</option>
                  {endCompResultArray.map((item) => (
                    <option value={item} key={item}>
                      {item}
                    </option>
                  ))}
                </select>
              </div>
              <div className='formWrap borderTop'>
                <label className='label'>1차 성과평가연도</label>
                <select onChange={(e) => { setStartyear(e.target.value) }} value={startyear ? startyear : "default"}>
                  <option value="default" disabled>선택하세요</option>
                  {yearArray.map((item) => (
                    <option value={item} key={item}>
                      {item}
                    </option>
                  ))}
                </select>
              </div>
              <div className='formWrap borderTop'>
                <label className='label'>1차 성과평가결과</label>
                <select onChange={(e) => { setStartresult(e.target.value) }} value={startresult ? startresult : "default"}>
                  <option value="default" disabled>선택하세요</option>
                  {startResultArray.map((item) => (
                    <option value={item} key={item}>
                      {item}
                    </option>
                  ))}
                </select>
              </div>
              <div className='formWrap borderTop'>
                <label className='label'>2차 성과평가연도</label>
                <input
                  name="endyear"
                  placeholder="연도를 입력하세요"
                  onChange={onChange}
                  value={endyear || ""}
                />
              </div>
              <div className='formWrap borderTop'>
                <label className='label'>2차 성과평가결과</label>
                <select onChange={(e) => { setEndresult(e.target.value) }} value={endresult ? endresult : "default"}>
                  <option value="default" disabled>선택하세요</option>
                  {endResultArray.map((item) => (
                    <option value={item} key={item}>
                      {item}
                    </option>
                  ))}
                </select>
              </div>
              <div className='formWrap borderTop'>
                <label className='label'>재무성과(원)</label>
                <input
                  name="result"
                  placeholder="성과를 입력하세요"
                  onChange={onChange}
                  value={result || ""}
                />
              </div>
              <div className='formWrap borderTop'>
                <label className='label'>사후관리</label>
                <select onChange={(e) => { setColor(e.target.value) }} value={color ? color : "default"}>
                  <option value="default" disabled>선택하세요</option>
                  {colorArray.map((item) => (
                    <option value={item} key={item}>
                      {item}
                    </option>
                  ))}
                </select>
              </div>
            </div>
            <h3>다중입력</h3>
            <div className='formGroup'>
              <div className='formWrap'>
                <label className='label'>관리지표</label>
                <textarea
                  name="indi"
                  placeholder="입력하세요"
                  onChange={onChange}
                  value={indi || ""}
                  rows={5}
                ></textarea>
              </div>
              <div className='formWrap'>
                <label className='label'>단위</label>
                <textarea
                  name="unit"
                  placeholder="입력하세요"
                  onChange={onChange}
                  value={unit || ""}
                  rows={5}
                ></textarea>
              </div>
              <div className='formWrap'>
                <label className='label'>수치</label>
                <textarea
                  name="datay0"
                  placeholder="입력하세요"
                  onChange={onChange}
                  value={datay0 || ""}
                  rows={5}
                ></textarea>
              </div>
              <div className='formWrap'>
                <label className='label'>Y+1</label>
                <textarea
                  name="datay1"
                  placeholder="입력하세요"
                  onChange={onChange}
                  value={datay1 || ""}
                  rows={5}
                ></textarea>
              </div>
              <div className='formWrap borderTop'>
                <label className='label'>Y+2</label>
                <textarea
                  name="datay2"
                  placeholder="입력하세요"
                  onChange={onChange}
                  value={datay2 || ""}
                  rows={5}
                ></textarea>
              </div>
              <div className='formWrap borderTop'>
                <label className='label'>Y+3</label>
                <textarea
                  name="datay3"
                  placeholder="입력하세요"
                  onChange={onChange}
                  value={datay3 || ""}
                  rows={5}
                ></textarea>
              </div>
              <div className='formWrap borderTop'>
                <label className='label'>Y+4</label>
                <textarea
                  name="datay4"
                  placeholder="입력하세요"
                  onChange={onChange}
                  value={datay4 || ""}
                  rows={5}
                ></textarea>
              </div>
              <div className='formWrap borderTop'>
                <label className='label'>Y+5</label>
                <textarea
                  name="datay5"
                  placeholder="입력하세요"
                  onChange={onChange}
                  value={datay5 || ""}
                  rows={5}
                ></textarea>
              </div>
            </div>
          </div>
          <div className='controll'>
            <button className={'button back'} onClick={() => { onBack() }}>목록</button>
            {location.state && <button className={'button delete'} onClick={() => { onDelete() }}>삭제</button>}
            {location.state ? <button className={'button'} onClick={() => { onUpdate() }}>수정</button> : <button className={'button'} disabled={!id} onClick={() => { onSave() }}>저장</button>}
          </div>
        </div>
      </div>
    </>
  );
}

App.defaultProps = {};

export default App;
