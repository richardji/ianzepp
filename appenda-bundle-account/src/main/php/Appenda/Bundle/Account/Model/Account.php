<?php

/**
 * The MIT License
 * 
 * Copyright (c) 2009 Ian Zepp
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 * @author Ian Zepp
 * @package Appenda_Bundle_Account
 */

require_once "Appenda/Bundle/Account/Model.php";

class Appenda_Bundle_Account_Model_Account extends Appenda_Bundle_Account_Model
{
	/**
	 * Enter description here...
	 *
	 * @return Zend_Db_Table_Rowset_Abstract
	 */
	public function findAddresses ()
	{
		return $this->findManyToManyRowset ("Appenda_Bundle_Account_Table_Account", "Appenda_Bundle_Account_Table_Address");
	}
	
	/**
	 * Enter description here...
	 *
	 * @return Zend_Db_Table_Rowset_Abstract
	 */
	public function findContacts ()
	{
		return $this->findManyToManyRowset ("Appenda_Bundle_Account_Table_Account", "Appenda_Bundle_Account_Table_Contact");
	}
	
	/**
	 * Enter description here...
	 *
	 * @return Zend_Db_Table_Rowset_Abstract
	 */
	public function findPhones ()
	{
		return $this->findManyToManyRowset ("Appenda_Bundle_Account_Table_Account", "Appenda_Bundle_Account_Table_Phone");
	}
	
	/**
	 * Enter description here...
	 *
	 * @param SimpleXMLElement $xml
	 * @return SimpleXMLElement
	 */
	public function toXml (SimpleXMLElement $xml)
	{
		$xml->{"id"} = $this->{"account_id"};
		$xml->{"name"} = $this->{"name"};
		$xml->{"type"} = $this->{"type"};
		
		foreach ($this->findContacts () as $contact)
		{
			$xml->addChild ("contact", $contact->{"id"});
		}
		
		foreach ($this->findAddresses () as $address)
		{
			$address->toXml ($xml->addChild ("address"));
		}
		
		foreach ($this->findPhones () as $phone)
		{
			$phone->toXml ($xml->addChild ("phone"));
		}
		
		return $xml;
	}
}
