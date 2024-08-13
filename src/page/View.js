

import React, { useContext, useState, useEffect, useMemo, useRef } from 'react';
import { isMobile } from 'react-device-detect';
import { useHistory, useLocation } from "react-router-dom";
import { doc, getDoc } from 'firebase/firestore';
import 'moment/locale/ko';
import context from '../component/Context';

import logo from '../assets/logo.svg';

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
            borderCollapse: "separate",
            borderSpacing: 0,
            border: "2px solid #000",
            backgroundColor: "#f5f5f7",
            fontSize: isMobile ? "14px" : "12pt",
            tableLayout: "fixed",
            backgroundImage: "url("+logo+")",
            backgroundRepeat: "no-repeat",
            backgroundPosition: "center",
            backgroundSize: "48%",
            backgroundBlendMode: "luminosity",
            /* filter: grayscale(100%)*/
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
                padding: "8px 21px",
                height: "56px",
                backgroundColor:  "rgba(255, 255, 255, 0.9)",
                wordBreak: "keep-all",
                textAlign: "left",
                letterSpacing: "1.2pt",
                borderRight: "1px solid rgba(0,0,0,0.3)",
                borderLeft: "1px solid rgba(0,0,0,0.3)",
            },
            tdML: {
                //borderBottom: isMobile ? "1px solid #d3d3d3" : "0.5pt solid #d3d3d3",
                fontWeight: "600",
                padding: "8px 21px",
                height: "56px",
                backgroundColor:  "rgba(255, 255, 255, 0.9)",
                wordBreak: "keep-all",
                textAlign: "left",
                letterSpacing: "1.2pt",
                borderLeft: "1px solid rgba(0,0,0,0.3)",
            },
            tdMR: {
                //borderBottom: isMobile ? "1px solid #d3d3d3" : "0.5pt solid #d3d3d3",
                fontWeight: "600",
                padding: "8px 21px",
                height: "56px",
                backgroundColor:  "rgba(255, 255, 255, 0.9)",
                wordBreak: "keep-all",
                textAlign: "left",
                letterSpacing: "1.2pt",
                borderRight: "1px solid rgba(0,0,0,0.3)",
            },
            tdT: {
                //borderTop: isMobile ? "2px double #d3d3d3" : "0.5pt double #d3d3d3",
                fontWeight: "600",
                padding: "8px 21px",
                height: "56px",
                backgroundColor:  "rgba(255, 255, 255, 0.9)",
                wordBreak: "keep-all",
                textAlign: "left",
                letterSpacing: "1.2pt",
                borderRadius: "18px 18px 0 0",
                borderTop: "1px solid rgba(0,0,0,0.3)",
                borderRight: "1px solid rgba(0,0,0,0.3)",
                borderLeft: "1px solid rgba(0,0,0,0.3)",
            },
            tdTL: {
                //borderTop: isMobile ? "2px double #d3d3d3" : "0.5pt double #d3d3d3",
                fontWeight: "600",
                padding: "8px 21px",
                height: "56px",
                backgroundColor:  "rgba(255, 255, 255, 0.9)",
                wordBreak: "keep-all",
                textAlign: "left",
                letterSpacing: "1.2pt",
                borderRadius: "18px 0 0 0",
                borderTop: "1px solid rgba(0,0,0,0.3)",
                borderLeft: "1px solid rgba(0,0,0,0.3)",
            },
            tdTR: {
                //borderTop: isMobile ? "2px double #d3d3d3" : "0.5pt double #d3d3d3",
                fontWeight: "600",
                padding: "8px 21px",
                height: "56px",
                backgroundColor:  "rgba(255, 255, 255, 0.9)",
                wordBreak: "keep-all",
                textAlign: "left",
                letterSpacing: "1.2pt",
                borderRadius: "0 18px 0 0",
                borderTop: "1px solid rgba(0,0,0,0.3)",
                borderRight: "1px solid rgba(0,0,0,0.3)",
            },
            tdBL: {
                //borderTop: isMobile ? "2px double #d3d3d3" : "0.5pt double #d3d3d3",
                fontWeight: "600",
                padding: "8px 21px",
                height: "56px",
                backgroundColor:  "rgba(255, 255, 255, 0.9)",
                wordBreak: "keep-all",
                textAlign: "left",
                letterSpacing: "1.2pt",
                borderRadius: "0 0 0 18px",
                borderBottom: "1px solid rgba(0,0,0,0.3)",
                borderLeft: "1px solid rgba(0,0,0,0.3)",
            },
            tdBR: {
                //borderTop: isMobile ? "2px double #d3d3d3" : "0.5pt double #d3d3d3",
                fontWeight: "600",
                padding: "8px 21px",
                height: "56px",
                backgroundColor:  "rgba(255, 255, 255, 0.9)",
                wordBreak: "keep-all",
                textAlign: "left",
                letterSpacing: "1.2pt",
                borderRadius: "0 0 18px 0",
                borderBottom: "1px solid rgba(0,0,0,0.3)",
                borderRight: "1px solid rgba(0,0,0,0.3)",
            },
            tdS: {
                height: "24px"
            },
            tdL: {
                //borderRight: isMobile ? "2px double #d3d3d3" : "0.5pt double #d3d3d3",
            },
            tdR: {
                //borderLeft: isMobile ? "2px double #d3d3d3" : "0.5pt double #d3d3d3",
            },
            tdB: {
                //borderBottom: isMobile ? "2px double #d3d3d3" : "0.5pt double #d3d3d3",
                backgroundColor:  "rgba(255, 255, 255, 0.9)",
            },
            tdU: {
                fontWeight: "600",
                padding: "8px 21px",
                height: "56px",
                backgroundColor:  "rgba(255, 255, 255, 0.9)",
                wordBreak: "keep-all",
                textAlign: "left",
                letterSpacing: "1.2pt",
                //borderBottom: isMobile ? "2px double #d3d3d3" : "1pt double #efefef",
                borderRadius: "0 0 18px 18px",
                borderBottom: "1px solid rgba(0,0,0,0.3)",
                borderRight: "1px solid rgba(0,0,0,0.3)",
                borderLeft: "1px solid rgba(0,0,0,0.3)",
            },
            tdZ: {
                fontWeight: "600",
                padding: "8px 21px",
                backgroundColor:  "rgba(255, 255, 255, 0.9)",
                wordBreak: "keep-all",
                textAlign: "left",
                letterSpacing: "1.2pt",
                //borderBottom: isMobile ? "2px double #d3d3d3" : "1pt double #efefef",
                borderRadius: "0 0 18px 18px",
                borderBottom: "1px solid rgba(0,0,0,0.3)",
                borderRight: "1px solid rgba(0,0,0,0.3)",
                borderLeft: "1px solid rgba(0,0,0,0.3)",
            },
            tde: {
                fontWeight: "600",
                padding: "6px 42px",
                height: "54px",
                wordBreak: "keep-all",
                textAlign: "left",
                letterSpacing: "1.2pt",
                backgroundColor:  "rgba(255, 255, 255, 0.9)",
                borderRight: "1px solid rgba(0,0,0,0.3)",
                borderLeft: "1px solid rgba(0,0,0,0.3)",
            },
            foot: {
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
        // eslint-disable-next-line
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
            <div className='view'>
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
                                <col width="auto" />
                                <col width={isMobile ? "16px" : "24px"} />
                            </colgroup>
                            <thead>
                                <tr>
                                    <th style={style.table.th} colSpan={4}>과제명&nbsp;:&nbsp;{title}</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td></td><td style={style.table.tdT} colSpan={2}>■ 관리번호&nbsp;:&nbsp;{id}</td><td></td>
                                </tr>
                                <tr>
                                    <td></td><td style={style.table.td} colSpan={2}>■ 확인번호&nbsp;:&nbsp;{checknum}</td><td></td>
                                </tr>
                                <tr>
                                    <td></td><td style={style.table.tdU} colSpan={2}>■ 팀장&nbsp;:&nbsp;{leader}</td><td></td>
                                </tr>
                                <tr>
                                    <td style={style.table.tdS} colSpan={4}></td>
                                </tr>
                                {
                                    isMobile ?
                                        <>
                                            <tr>
                                            <td></td><td style={style.table.tdT} colSpan={2}>■ 1차완료 평가연도&nbsp;:&nbsp;{startcompyear}</td><td></td>
                                            </tr>
                                            <tr>
                                            <td></td><td style={style.table.td} colSpan={2}>■ 1차완료 평가결과&nbsp;:&nbsp;{startcompresult}</td><td></td>
                                            </tr>
                                            <tr>
                                            <td></td><td style={style.table.td} colSpan={2}>■ 2차완료 평가연도&nbsp;:&nbsp;{endcompyear}</td><td></td>
                                            </tr>
                                            <tr>
                                            <td></td><td style={style.table.td} colSpan={2}>■ 2차완료 평가결과&nbsp;:&nbsp;{endcompresult}</td><td></td>
                                            </tr>
                                            <tr>
                                            <td></td><td style={style.table.td} colSpan={2}>■ 1차 성과 평가연도&nbsp;:&nbsp;{startyear}</td><td></td>
                                            </tr>
                                            <tr>
                                            <td></td><td style={style.table.td} colSpan={2}>■ 1차 성과 평가결과&nbsp;:&nbsp;{startresult}</td><td></td>
                                            </tr>
                                            <tr>
                                            <td></td><td style={style.table.td} colSpan={2}>■ 2차 성과 평가연도&nbsp;:&nbsp;{endyear}</td><td></td>
                                            </tr>
                                            <tr>
                                            <td></td><td style={style.table.tdU} colSpan={2}>■ 2차 성과 평가결과&nbsp;:&nbsp;{endresult}</td><td></td>
                                            </tr>
                                        </> :
                                        <>
                                            <tr>
                                                <td></td><td style={style.table.tdTL}>■ 1차완료 평가연도&nbsp;:&nbsp;{startcompyear}</td><td style={style.table.tdTR}>■ 1차완료 평가결과&nbsp;:&nbsp;{startcompresult}</td><td style={style.table.tdR}></td>
                                            </tr>
                                            <tr>
                                                <td></td><td style={style.table.tdML}>■ 2차완료 평가연도&nbsp;:&nbsp;{endcompyear}</td><td style={style.table.tdMR}>■ 2차완료 평가결과&nbsp;:&nbsp;{endcompresult}</td><td style={style.table.tdR}></td>
                                            </tr>
                                            <tr>
                                                <td></td><td style={style.table.tdML}>■ 1차 성과 평가연도&nbsp;:&nbsp;{startyear}</td><td style={style.table.tdMR}>■ 1차 성과 평가결과&nbsp;:&nbsp;{startresult}</td><td style={style.table.tdR}></td>
                                            </tr>
                                            <tr>
                                                <td></td><td style={style.table.tdBL}>■ 2차 성과 평가연도&nbsp;:&nbsp;{endyear}</td><td style={style.table.tdBR}>■ 2차 성과 평가결과&nbsp;:&nbsp;{endresult}</td><td style={style.table.tdR}></td>
                                            </tr>
                                        </>
                                }
                                <tr>
                                    <td style={style.table.tdS} colSpan={4}></td>
                                </tr>

                                <tr>
                                    <td style={style.table.tdL}></td><td style={style.table.tdT} colSpan={2}>■ 재무성과(원)&nbsp;:&nbsp;{result}</td><td style={style.table.tdR}></td>
                                </tr>
                                <tr>
                                    <td style={style.table.tdL}></td><td style={style.table.td} colSpan={2}>■ 관리지표&nbsp;:&nbsp;{indi[0]}</td><td style={style.table.tdR}></td>
                                </tr>
                                <tr>
                                    <td style={style.table.tdL}></td><td style={style.table.tde} colSpan={2}>○ 단위&nbsp;:&nbsp;{unit[0]}</td><td style={style.table.tdR}></td>
                                </tr>
                                <tr>
                                    <td style={style.table.tdL}></td><td style={style.table.tde} colSpan={2}>○ 수치&nbsp;:&nbsp;{datay0[0]}</td><td style={style.table.tdR}></td>
                                </tr>
                                <tr>
                                    <td style={style.table.tdL}></td><td style={style.table.tdZ} colSpan={2}></td><td style={style.table.tdR}></td>
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
