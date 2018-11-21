package com.koscom.loan.dao;



import com.koscom.domain.CooconGoodsFavoriteInfo;
import com.koscom.finance.model.TxFcTransmitVO;
import com.koscom.goods.model.GoodsVO;

public interface LoanMapper {
	
	/**
	 * 신청정보 insert
	 * @param txFcTransmitVO
	 * @return
	 */
	int insertLoanInfo(TxFcTransmitVO txFcTransmitVO);
	
	/**
	 * 부가정보  update 
	 * @param txFcTransmitVO
	 * @return
	 */
	int modifyLoanAdditional(TxFcTransmitVO txFcTransmitVO);
	
	/**
	 * 신청정보 상품 insert
	 * @param goodsVO
	 * @return
	 */
	int insertLoanGoodsInfo(GoodsVO goodsVO);

	/**
	 * 즐겨찾기   insert
	 * @param cooconGoodsFavoriteInfo
	 * @return
	 */
	int insertLoanGoodsChoice(CooconGoodsFavoriteInfo cooconGoodsFavoriteInfo);
	
	/**
	 * 즐겨찾기 delete
	 * @param cooconGoodsFavoriteInfo
	 * @return
	 */
	int deleteLoanGoodsChoice(CooconGoodsFavoriteInfo cooconGoodsFavoriteInfo);
	
	/**
	 * tx_fc_transmit 정보 select
	 * @param String
	 * @return TxFcTransmitVO
	 */
	TxFcTransmitVO getTxFcTransmitInfoForMsg(String no_bunch);
}
