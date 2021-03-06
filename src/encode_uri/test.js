const expect = require('chai').expect;
const {BigQuery} = require('@google-cloud/bigquery');
const bigquery = new BigQuery();

describe('encode_uri', () => {
    let rows;
    before(async function () {
        [rows] = await bigquery.query('SELECT `bigquery-lib.udf.encode_uri`("https://www.example.com/?name=ståle&car=saab")');
    });
    it('has expected value', () => expect(rows[0].f0_).to.equal('https://www.example.com/?name=st%C3%A5le&car=saab'));
});