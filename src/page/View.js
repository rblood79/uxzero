

import React, { useContext, useState, useEffect, useMemo, useRef } from 'react';
import { isMobile } from 'react-device-detect';
import { useHistory, useLocation } from "react-router-dom";
import { doc, getDoc } from 'firebase/firestore';
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

    const tableRef = useRef();

    const memoizedInputs = useMemo(() => ({
        id: data?.ID || "",
        checknum: data?.CHECKNUM || "",
        leader: data?.LEADER || "",
        title: data?.TITLE || "",
        endcompyear: data?.ENDCOMPYEAR || "",
        endyear: data?.ENDYEAR || "",
        result: data?.RESULT || "",
        indi: data?.INDI.split('\n') || [],
        unit: data?.UNIT.split('\n') || [],
        datay0: data?.DATAY0.split('\n') || [],
        datay1: data?.DATAY1 || "",
        datay2: data?.DATAY2 || "",
        datay3: data?.DATAY3 || "",
        datay4: data?.DATAY4 || "",
        datay5: data?.DATAY5 || "",

    }), [data]);

    const [inputs, setInputs] = useState(memoizedInputs);
    const { id, checknum, leader, title, endcompyear, endyear, result, indi, unit, datay0 } = inputs;


    const style = {
        table: {
            width: isMobile ? "100%" : "210mm",
            height: isMobile ? "100%" : "297mm",
            borderCollapse: "collapse",
            border: "2px solid #000",
            backgroundColor: "#fff",
            fontSize: isMobile ? "14px" : "12pt",
            tableLayout: "fixed",
            th: {
                fontWeight: "600",
                padding: "4px 16px",
                height: "68px",
                wordBreak: "keep-all",
                fontSize: isMobile ? "14px" : "14pt",
                textDecoration: "underline",
                textUnderlineOffset: "4px",
            },
            td: {
                //borderBottom: isMobile ? "1px solid #d3d3d3" : "0.5pt solid #d3d3d3",
                fontWeight: "600",
                padding: "6px 16px",
                height: "56px",
                //minHeight: "56px",
                wordBreak: "keep-all",
                textAlign: "left",
                letterSpacing: "1.2pt",
            },
            tdT: {
                borderTop: isMobile ? "2px solid #d3d3d3" : "1pt solid #d3d3d3",
                fontWeight: "600",
                padding: "6px 16px",
                height: "56px",
                //minHeight: "56px",
                wordBreak: "keep-all",
                textAlign: "left",
                letterSpacing: "1.2pt",
            },
            tdL: {
                borderRight: isMobile ? "2px solid #d3d3d3" : "1pt solid #d3d3d3",
            },
            tdR: {
                borderLeft: isMobile ? "2px solid #d3d3d3" : "1pt solid #d3d3d3",
            },
            tdB: {
                borderBottom: isMobile ? "2px solid #d3d3d3" : "1pt solid #d3d3d3",
            },
            tde: {
                fontWeight: "600",
                padding: "6px 42px",
                height: "56px",
                wordBreak: "keep-all",
                textAlign: "left",
                paddingLeft: "28px",
                letterSpacing: "1.2pt",
            },
            foot :{
                height: isMobile ? "16px" : "24px",
            }
        }
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

    useEffect(() => {
        if (data) {
            setInputs(memoizedInputs);
            setStartcompyear(data.STARTCOMPYEAR);
            setStartcompresult(data.STARTCOMPRESULT);
            setEndcompresult(data.ENDCOMPRESULT);
            setStartyear(data.STARTYEAR);
            setStartresult(data.STARTRESULT);
            setEndresult(data.ENDRESULT);
        }
    }, [data, memoizedInputs]);

    useEffect(() => {
        !user ? history.push('/') : onLoad();
    }, []);


    const onBack = () => {
        //history.push('/result', { updated: false });
        history.goBack()
    }

    const onPrint = () => {
        const style = document.createElement('style');
        style.media = 'print';
        style.innerHTML = `
            body{
                background: #fff;
                padding: 0mm;
                height: 100% !important;
            }
                
            table {
                height: calc(297mm - 20mm) !important;

            }
            @page {
                size: A4 portrait !important;
                margin: 10mm !important;
            }
        `;
        // head 태그에 스타일을 추가합니다.
        document.head.appendChild(style);
        window.print();
        // 인쇄 후 스타일 시트를 제거합니다.
        document.head.removeChild(style);
    }

    return (
        <>
            <div className='order'>
                <div className='users'>
                    <div className='controll'>
                        <button className={'button back'} onClick={onBack}>이전</button>
                        {!isMobile && <button className={'button'} onClick={onPrint}>인쇄</button>}
                    </div>
                    <div className='tableContents'>
                        <table ref={tableRef} style={style.table}>
                            <colgroup>
                                <col width={isMobile ? "16px" : "24px"} />
                                <col width="auto" />
                                <col width={isMobile ? "16px" : "24px"} />
                            </colgroup>
                            <thead>
                                <tr>
                                    <th style={style.table.th} colSpan={3}>과제명&nbsp;:&nbsp;{title}</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td style={style.table.tdL}></td><td style={style.table.tdT}>□ 관리번호&nbsp;:&nbsp;{id}</td><td style={style.table.tdR}></td>
                                </tr>
                                <tr>
                                    <td style={style.table.tdL}></td><td style={style.table.td}>□ 확인번호&nbsp;:&nbsp;{checknum}</td><td style={style.table.tdR}></td>
                                </tr>
                                <tr>
                                    <td style={style.table.tdL}></td><td style={style.table.td}>□ 팀장&nbsp;:&nbsp;{leader}</td><td style={style.table.tdR}></td>
                                </tr>
                                <tr>
                                    <td style={style.table.tdL}></td><td style={style.table.td}>□ 1차완료 평가연도&nbsp;:&nbsp;{startcompyear}</td><td style={style.table.tdR}></td>
                                </tr>
                                <tr>
                                    <td style={style.table.tdL}></td><td style={style.table.td}>□ 1차완료 평가결과&nbsp;:&nbsp;{startcompresult}</td><td style={style.table.tdR}></td>
                                </tr>
                                <tr>
                                    <td style={style.table.tdL}></td><td style={style.table.td}>□ 2차완료 평가연도&nbsp;:&nbsp;{endcompyear}</td><td style={style.table.tdR}></td>
                                </tr>
                                <tr>
                                    <td style={style.table.tdL}></td><td style={style.table.td}>□ 2차완료 평가결과&nbsp;:&nbsp;{endcompresult}</td><td style={style.table.tdR}></td>
                                </tr>
                                <tr>
                                    <td style={style.table.tdL}></td><td style={style.table.td}>□ 1차 성과 평가연도&nbsp;:&nbsp;{startyear}</td><td style={style.table.tdR}></td>
                                </tr>
                                <tr>
                                    <td style={style.table.tdL}></td><td style={style.table.td}>□ 1차 성과 평가결과&nbsp;:&nbsp;{startresult}</td><td style={style.table.tdR}></td>
                                </tr>
                                <tr>
                                    <td style={style.table.tdL}></td><td style={style.table.td}>□ 2차 성과 평가연도&nbsp;:&nbsp;{endyear}</td><td style={style.table.tdR}></td>
                                </tr>
                                <tr>
                                    <td style={style.table.tdL}></td><td style={style.table.td}>□ 2차 성과 평가결과&nbsp;:&nbsp;{endresult}</td><td style={style.table.tdR}></td>
                                </tr>
                                <tr>
                                    <td style={style.table.tdL}></td><td style={style.table.td}>□ 재무성과(원)&nbsp;:&nbsp;{result}</td><td style={style.table.tdR}></td>
                                </tr>
                                <tr>
                                    <td style={style.table.tdL}></td><td style={style.table.td}>□ 관리지표&nbsp;:&nbsp;{indi[0]}</td><td style={style.table.tdR}></td>
                                </tr>
                                <tr>
                                    <td style={style.table.tdL}></td><td style={style.table.tde}>○ 단위&nbsp;:&nbsp;{unit[0]}</td><td style={style.table.tdR}></td>
                                </tr>
                                <tr>
                                    <td style={style.table.tdL}></td><td style={style.table.tde}>○ 수치&nbsp;:&nbsp;{datay0[0]}</td><td style={style.table.tdR}></td>
                                </tr>
                                <tr>
                                    <td style={style.table.tdL}></td><td style={style.table.tdB}></td><td style={style.table.tdR}></td>
                                </tr>
                                <tr>
                                    <th colSpan={3} style={style.table.foot}></th>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </>
    );

}

App.defaultProps = {

};

export default App;
