import _ from 'lodash';
import React, { useContext, useState, useEffect, useMemo, useCallback } from 'react';
import { useHistory, useLocation } from "react-router-dom";
import { doc, deleteDoc, getDoc, setDoc } from 'firebase/firestore';
import moment from "moment";
import 'moment/locale/ko';
import context from '../component/Context';

const App = (props) => {
  const history = useHistory();
  const state = useContext(context);
  const location = useLocation();
  const { user, year } = state;
  const [data, setData] = useState(null);
  const [startcompyear, setStartcompyear] = useState(null);
  const [startcompresult, setStartcompresult] = useState(null);
  const [endcompresult, setEndcompresult] = useState(null);
  const [startyear, setStartyear] = useState(null);
  const [startresult, setStartresult] = useState(null);
  const [endresult, setEndresult] = useState(null);
  const [color, setColor] = useState(null);

  const [rowCount] = useState(5);

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

  const tempArr = (e) => {
    return e.split('\n');
  };

  const onChange = (e) => {
    const { name, value } = e.target;
    const lines = tempArr(value)//value.split('\n');

    if (lines.length <= 10) {
      setInputs({
        ...inputs,
        [name]: value
      });
      //setRowCount(Math.max(rowCount,lines.length))
    } else {
      // 10줄을 초과하는 경우 첫 10줄만 유지
      const limitedValue = lines.slice(0, 10).join('\n');
      setInputs({
        ...inputs,
        [name]: limitedValue
      });
    }
    /*setInputs({
      ...inputs,
      [name]: value || "",
    });*/
  };

  const startCompResultArray = ["완료", "조건부완료", "중단", "연장", "미평가"];
  const endCompResultArray = ["완료", "조건부완료", "중단", "연장", "1차완료", "미평가"];
  const startResultArray = ["인증", "인증(대상)", "인증(금상)", "인증(은상)", "인증(동상)", "인증(장려)", "미인증(중단)", "미인증(재도전)"];
  const endResultArray = ["인증", "인증(대상)", "인증(금상)", "인증(은상)", "인증(동상)", "인증(장려)", "미인증(중단)", "1차인증"];
  const colorArray = ["red", "green", "yellow"];

  const [minYear] = useState(year[0]);
  const [maxYear] = useState(year[1]);

  /*const getYearRange = (startYear, endYear) => {
    const yearArray = [];
    // 시작 연도부터 종료 연도까지 반복문을 돌며 배열에 연도를 추가합니다.
    for (let year = startYear; year <= endYear; year++) {
      yearArray.push(year.toString());
    }
    return yearArray;
  };*/

  const useYearRange = (startYear, endYear) => {
    const getYearRange = useCallback(() => {
      const yearArray = [];
      for (let year = startYear; year <= endYear; year++) {
        yearArray.push(year.toString());
      }
      return yearArray;
    }, [startYear, endYear]);
    // useMemo로 getYearRange의 결과를 메모이제이션
    const years = useMemo(() => getYearRange(), [getYearRange]);

    return years;
  };

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

  const onBack = () => {
    history.goBack();//push('/result', { updated: false });
  }

  const onView = () => {
    history.push({
      pathname: '/view',
      state: { userCell: id }
    });
  };

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
    //await updateDoc(doc(props.manage, id), {
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
            <div className='formGroup'>
              <div className='formWrap'>
                <label className='label' htmlFor="TITL">과제명</label>
                <input
                  id='TITL'
                  name="title"
                  placeholder="입력하세요"
                  onChange={onChange}
                  value={title || ""}
                />
              </div>
              <div className='formWrap borderTop'>
                <label className='label' htmlFor="IDN">관리번호</label>
                <input
                  id='IDN'
                  name="id"
                  placeholder="등록후 변경 불가"
                  onChange={onChange}
                  value={id || ""}
                  disabled={data}
                />
              </div>
              <div className='formWrap borderTop'>
                <label className='label' htmlFor="CN">확인번호</label>
                <input
                  id='CN'
                  name="checknum"
                  placeholder="입력하세요"
                  onChange={onChange}
                  value={checknum || ""}
                />
              </div>
              <div className='formWrap borderTop'>
                <label className='label' htmlFor="LD">팀장</label>
                <input
                  id='LD'
                  name="leader"
                  placeholder="입력하세요"
                  onChange={onChange}
                  value={leader || ""}
                />
              </div>

              <div className='formWrap spanN borderTop'>
                <label className='label' htmlFor='SCY'>1차 완료평가연도</label>
                <select id="SCY" onChange={(e) => { setStartcompyear(e.target.value) }} value={startcompyear ? startcompyear : "default"}>
                  <option value="default" disabled>선택하세요</option>
                  {
                    useYearRange(minYear, maxYear).map((item) => (
                      <option value={item} key={item}>
                        {item}
                      </option>
                    ))
                  }
                </select>
              </div>
              <div className='formWrap borderTop'>
                <label className='label' htmlFor='SCR'>1차 완료평가결과</label>
                <select id="SCR" onChange={(e) => { setStartcompresult(e.target.value) }} value={startcompresult ? startcompresult : "default"}>
                  <option value="default" disabled>선택하세요</option>
                  {startCompResultArray.map((item) => (
                    <option value={item} key={item}>
                      {item}
                    </option>
                  ))}
                </select>
              </div>
              <div className='formWrap borderTop'>
                <label className='label' htmlFor="ECY">2차 완료평가연도</label>
                <input
                  id='ECY'
                  name="endcompyear"
                  placeholder="입력하세요"
                  onChange={onChange}
                  value={endcompyear || ""}
                />
              </div>
              <div className='formWrap borderTop'>
                <label className='label' htmlFor='ECR'>2차 완료평가결과</label>
                <select id="ECR" onChange={(e) => { setEndcompresult(e.target.value) }} value={endcompresult ? endcompresult : "default"}>
                  <option value="default" disabled>선택하세요</option>
                  {endCompResultArray.map((item) => (
                    <option value={item} key={item}>
                      {item}
                    </option>
                  ))}
                </select>
              </div>
              <div className='formWrap spanN borderTop'>
                <label className='label' htmlFor='SY'>1차 성과평가연도</label>
                <select id="SY" onChange={(e) => { setStartyear(e.target.value) }} value={startyear ? startyear : "default"}>
                  <option value="default" disabled>선택하세요</option>
                  {
                    useYearRange(minYear, maxYear).map((item) => (
                      <option value={item} key={item}>
                        {item}
                      </option>
                    ))
                  }
                </select>
              </div>
              <div className='formWrap borderTop'>
                <label className='label' htmlFor='SR'>1차 성과평가결과</label>
                <select id="SR" onChange={(e) => { setStartresult(e.target.value) }} value={startresult ? startresult : "default"}>
                  <option value="default" disabled>선택하세요</option>
                  {startResultArray.map((item) => (
                    <option value={item} key={item}>
                      {item}
                    </option>
                  ))}
                </select>
              </div>
              <div className='formWrap borderTop'>
                <label className='label' htmlFor="EY">2차 성과평가연도</label>
                <input
                  id='EY'
                  name="endyear"
                  placeholder="입력하세요"
                  onChange={onChange}
                  value={endyear || ""}
                />
              </div>
              <div className='formWrap borderTop'>
                <label className='label' htmlFor='ER'>2차 성과평가결과</label>
                <select id="ER" onChange={(e) => { setEndresult(e.target.value) }} value={endresult ? endresult : "default"}>
                  <option value="default" disabled>선택하세요</option>
                  {endResultArray.map((item) => (
                    <option value={item} key={item}>
                      {item}
                    </option>
                  ))}
                </select>
              </div>
              <div className='formWrap spanN borderTop'>
                <label className='label' htmlFor="RES">재무성과(원)</label>
                <input
                  id='RES'
                  name="result"
                  placeholder="입력하세요"
                  onChange={onChange}
                  value={result || ""}
                />
              </div>
              <div className='formWrap borderTop'>
                <label className='label' htmlFor="ID">관리지표<span className='red'>{tempArr(indi).length > 1 && tempArr(indi).length + '건'}</span></label>
                <textarea
                  id='ID'
                  name="indi"
                  placeholder="입력하세요"
                  onChange={onChange}
                  value={indi || ""}
                  rows={rowCount}
                ></textarea>
              </div>
              <div className='formWrap borderTop'>
                <label className='label' htmlFor="UN">단위<span className='red'>{tempArr(unit).length > 1 && tempArr(unit).length + '건'}</span></label>
                <textarea
                  id='UN'
                  name="unit"
                  placeholder="입력하세요"
                  onChange={onChange}
                  value={unit || ""}
                  rows={rowCount}
                ></textarea>
              </div>
              <div className='formWrap borderTop'>
                <label className='label' htmlFor="D0">수치<span className='red'>{tempArr(datay0).length > 1 && tempArr(datay0).length + '건'}</span></label>
                <textarea
                  id='D0'
                  name="datay0"
                  placeholder="입력하세요"
                  onChange={onChange}
                  value={datay0 || ""}
                  rows={rowCount}
                ></textarea>
              </div>
              <div className='formWrap'>
                <label className='label' htmlFor='CO'>사후관리상태</label>
                <select id="CO" onChange={(e) => { setColor(e.target.value) }} value={color ? color : "default"}>
                  <option value="default" disabled>선택하세요</option>
                  {colorArray.map((item) => (
                    <option value={item} key={item}>
                      {item}
                    </option>
                  ))}
                </select>
              </div>
              <div className='formWrap borderTop'>
                <label className='label' htmlFor="D1">Y+1<span className='red'>{tempArr(datay1).length > 1 && tempArr(datay1).length + '건'}</span></label>
                <textarea
                  id='D1'
                  name="datay1"
                  placeholder="입력하세요"
                  onChange={onChange}
                  value={datay1 || ""}
                  rows={rowCount}
                ></textarea>
              </div>
              <div className='formWrap borderTop'>
                <label className='label' htmlFor="D2">Y+2<span className='red'>{tempArr(datay2).length > 1 && tempArr(datay2).length + '건'}</span></label>
                <textarea
                  id='D2'
                  name="datay2"
                  placeholder="입력하세요"
                  onChange={onChange}
                  value={datay2 || ""}
                  rows={rowCount}
                ></textarea>
              </div>
              <div className='formWrap borderTop'>
                <label className='label' htmlFor="D3">Y+3<span className='red'>{tempArr(datay3).length > 1 && tempArr(datay3).length + '건'}</span></label>
                <textarea
                  id='D3'
                  name="datay3"
                  placeholder="입력하세요"
                  onChange={onChange}
                  value={datay3 || ""}
                  rows={5}
                ></textarea>
              </div>
              <div className='formWrap borderTop'>
                <label className='label' htmlFor="D4">Y+4<span className='red'>{tempArr(datay4).length > 1 && tempArr(datay4).length + '건'}</span></label>
                <textarea
                  id='D4'
                  name="datay4"
                  placeholder="입력하세요"
                  onChange={onChange}
                  value={datay4 || ""}
                  rows={rowCount}
                ></textarea>
              </div>
              <div className='formWrap borderTop'>
                <label className='label' htmlFor="D5">Y+5<span className='red'>{tempArr(datay5).length > 1 && tempArr(datay5).length + '건'}</span></label>
                <textarea
                  id='D5'
                  name="datay5"
                  placeholder="입력하세요"
                  onChange={onChange}
                  value={datay5 || ""}
                  rows={rowCount}
                ></textarea>
              </div>
            </div>
          </div>
          <div className='controll'>
            <button className={'button back'} onClick={onBack}>이전</button>
            {location.state && <button className={'button delete'} onClick={onDelete}>삭제</button>}
            {location.state ? <button className={'button edit'} onClick={onUpdate}>수정</button> : <button className={'button'} disabled={!id} onClick={onSave}>저장</button>}
            {location.state && <button className={'button detail'} onClick={onView}>출력</button>}
          </div>
        </div>
      </div>
    </>
  );
}

App.defaultProps = {};

export default App;
